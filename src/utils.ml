open Printf

exception Error of string
let _error s = raise (Error (sprintf "%s\n%!" s))
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
    let config_file = Filename.concat (Unix.getcwd()) "dream_config.json" in
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

  let init () =
    match Dream_config.get_string_opt "log" with
    | None -> ()
    | Some log_dir ->
      try
        let basename = Printf.sprintf "template_%s.log" (time_stamp ()) in
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
    | Error msg -> `Assoc [ ("status", `String "ERROR"); ("message", `String msg) ]
    (* TODO: add Error from project specific librairies  *)
    | exc -> `Assoc [ ("status", `String "BUG"); ("Unexpected exception", `String (Printexc.to_string exc)) ] in
  json
