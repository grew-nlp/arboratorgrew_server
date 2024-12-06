open Printf
open Conll
open Grewlib

exception Error of Yojson.Basic.t
let _error s = raise (Error (`String (sprintf "%s\n%!" s)))
let error s = Printf.ksprintf _error s

let _stop s = 
  ANSITerminal.eprintf [ANSITerminal.red] "ERROR: %s\n" s;
  exit 1
let stop s = Printf.ksprintf _stop s

let (warnings: Yojson.Basic.t list ref) = ref []
let warn s = warnings := (`String s) :: !warnings

let report_status json = 
  match json |> Yojson.Basic.Util.member "status" |> Yojson.Basic.Util.to_string with
  | "OK" -> "OK"
  | _ -> Yojson.Basic.pretty_to_string json

(* ================================================================================ *)
(* Dream_config *)
(* ============================================================================================= *)
module Dream_config = struct
  let current = ref []
  let load ?(required=[]) () =
    let open Yojson.Basic.Util in
    let config_file =
      if Array.length Sys.argv > 1
      then Sys.argv.(1)
      else error "a config file must be given in the command line" in
    try
      current :=
        config_file
        |> Yojson.Basic.from_file
        |> to_assoc;
      match List.filter (fun k -> not (List.mem_assoc k !current)) required with
      | [] -> ()
      | l -> stop "In config file, missing parameter(s): %s" (String.concat ", " l)
    with 
    | Sys_error msg -> stop "[load_config] %s" msg
    | Yojson__Common.Json_error (msg) -> stop "[load_config] %s" msg
    | Type_error (msg,_) -> stop "[load_config] %s" msg

  let get_string_opt key =
    match List.assoc_opt key !current with
    | Some (`String value) -> Some value
    | Some _ -> error "config for key `%s` must be of type string" key
    | None -> None
  let get_string key =
    match List.assoc_opt key !current with
    | Some (`String value) -> value
    | Some _ -> error "config for key `%s` must be of type string" key
    | None -> error "Undefined config for key `%s`" key

  let get_int key =
    match List.assoc_opt key !current with
    | Some (`Int value) -> value
    | Some _ -> error "config for key `%s` must be of type int" key
    | None -> error "Undefined config for key `%s`" key
end

(* ================================================================================ *)
(* Log *)
(* ================================================================================ *)
module Log = struct
  let out_ch = ref stdout

  let time_stamp () =
    let gm = Unix.localtime (Unix.time ()) in
    Printf.sprintf "%02d_%02d_%02d_%02d_%02d_%02d"
      (gm.Unix.tm_year - 100)
      (gm.Unix.tm_mon + 1)
      gm.Unix.tm_mday
      gm.Unix.tm_hour
      gm.Unix.tm_min
      gm.Unix.tm_sec

  let init ?(prefix="dream") () =
    match Dream_config.get_string_opt "log" with
    | None -> ()
    | Some log_dir ->
      try
        let basename = Printf.sprintf "%s_%s.log" prefix (time_stamp ()) in
        let filename = Filename.concat log_dir basename in
        out_ch := open_out filename
      with Sys_error msg -> stop "%s" msg

  let ts = ref 0.
  let start () = ts := Unix.gettimeofday ()
  let ms_from start = (Unix.gettimeofday () -. start) *. 1000.

  let _info s = 
    Printf.fprintf !out_ch "[%s] {%gms} %s\n%!" 
    (time_stamp ()) 
    (ms_from !ts)
    s
  let info s = Printf.ksprintf _info s
end

(* ================================================================================ *)
let wrap fct last_arg =
  warnings := [];
  Log.start();
  let json =
    try
      let data = fct last_arg in
      match !warnings with
      | [] -> `Assoc [ ("status", `String "OK"); ("data", data) ]
      | l -> `Assoc [ ("status", `String "WARNING"); ("messages", `List l); ("data", data) ]
    with
    | Error json_msg -> `Assoc [ ("status", `String "ERROR"); ("message", json_msg) ]
    | Sys_error msg -> `Assoc [ ("status", `String "ERROR"); ("message", `String msg) ]
    | Conll_error json_msg -> `Assoc [ ("status", `String "ERROR"); ("message", json_msg) ]
    | Grewlib.Error msg -> `Assoc [ ("status", `String "ERROR"); ("message", `String msg) ]
    | exc -> 
      let msg = sprintf "BUG [Unexpected exception], please report (%s)" (Printexc.to_string exc) in
        `Assoc [ ("status", `String "ERROR"); ("message", `String msg) ] in
  json

let reply json = Dream.respond (Yojson.Basic.pretty_to_string json)

let _reply_error s = 
  let msg = sprintf "%s\n%!" s in
  reply (`Assoc [ ("status", `String "ERROR"); ("message", `String msg) ])

let reply_error s = Printf.ksprintf _reply_error s

(* General function for handling request with a mix of parameter and files *)
let stream_request request = 
  let buff = Buffer.create 32 in
  let rec loop (param_map, file_list) =
    match%lwt Dream.upload request with
    | None -> Lwt.return (param_map, file_list)
    | Some (None, None, _) -> assert false 
    | Some (Some key, None, _) ->
      begin
        Buffer.clear buff;
        let rec save_chunk_param () =
          match%lwt Dream.upload_part request with
          | None -> loop (String_map.add key (Buffer.contents buff) param_map, file_list)
          | Some chunk -> bprintf buff "%s" chunk; save_chunk_param () in
        save_chunk_param ()
      end
    | Some (_, Some _, _) ->
      let filename = Filename.concat "upload" (sprintf "%.0f" (Unix.gettimeofday() *. 1000.)) in
      let out_ch = open_out filename in
      let rec save_chunk () =
        match%lwt Dream.upload_part request with
        | None -> close_out out_ch; loop (param_map, filename :: file_list)
        | Some chunk -> fprintf out_ch "%s%!" chunk; save_chunk () in
      save_chunk () in
  loop (String_map.empty, [])

