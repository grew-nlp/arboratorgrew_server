open Utils

(*   curl -X POST -d 'Some Data' 'http://localhost:8080/echo'    *)
let _echo_6 () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.post "/echo" (fun request ->
      let%lwt body = Dream.body request in
      Dream.respond
        ~headers:["Content-Type", "application/octet-stream"]
        body);
  ]

let _debug_8 () =
  Dream.run ~error_handler:Dream.debug_error_handler
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/bad"
      (fun _ ->
        Dream.empty `Bad_Request);

    Dream.get "/fail"
      (fun _ ->
        raise (Failure "The Web app failed!"));
  ]

let _log_a () =
  Dream.run ~error_handler:Dream.debug_error_handler
  @@ Dream.logger
  @@ Dream.router [

    Dream.get "/"
      (fun request ->
        Dream.log "Sending greeting to %s!" (Dream.client request);
        Dream.html "Good morning, world!");

    Dream.get "/fail"
      (fun _ ->
        Dream.warning (fun log -> log "Raising an exception!");
        raise (Failure "The Web app failed!"));
  ]

let _session_b () =
  Dream.run
  @@ Dream.logger
  @@ Dream.memory_sessions
  @@ fun request ->

    match Dream.session_field request "user" with
    | None ->
      let%lwt () = Dream.invalidate_session request in
      let%lwt () = Dream.set_session_field request "user" "alice" in
      Dream.html "You weren't logged in; but now you are!"

    | Some username ->
      Printf.ksprintf
        Dream.html "Welcome back, %s!" (Dream.html_escape username)

let _coookie_c () =
  Dream.run
  @@ Dream.set_secret "foo"
  @@ Dream.logger
  @@ fun request ->

    match Dream.cookie request "ui.language" with
    | Some value ->
      Printf.ksprintf
        Dream.html "Your preferred language is %s!" (Dream.html_escape value)

    | None ->
      let response = Dream.response "Set language preference; come again!" in
      Dream.add_header response "Content-Type" Dream.text_html;
      Dream.set_cookie response request "ui.language" "ut-OP";
      Lwt.return response


let form_route = 
  Dream.post "form"
  (fun request ->
    match%lwt Dream.form ~csrf:false request with
    | `Ok ["message", message] ->
      Dream.html (Printf.sprintf ">>>>%s<<<<" message)
    | _ ->
      Dream.empty `Bad_Request)

(* https://github.com/aantron/dream/tree/master/example/f-static *)
let static_route =
  Dream.get "/static/**" (Dream.static "static")

(* https://github.com/aantron/dream/tree/master/example/g-upload *)
let files_upload_route =
  Dream.post "files_upload" (fun request ->
    match%lwt Dream.multipart ~csrf:false request with
    | `Ok ["files", files] ->
      let json = wrap Services.report files in
      Log.info "<files_upload> ==> %s" (report_status json);
      Dream.respond (Yojson.Basic.pretty_to_string json)
    | _ -> Dream.empty `Bad_Request)



let report files =
  List.iter (fun (name_opt, size) ->
    let name =
      match name_opt with
      | None -> failwith "No name??"
      | Some n -> n in
    Printf.printf "name:%s size:%d\n%!" name size
  ) files;
  "Done"

let stream_upload_route = 
  Dream.post "stream_upload"
    (fun request ->
      let rec receive file_sizes =
        match%lwt Dream.upload request with
        | None -> Dream.html (report (List.rev file_sizes))
        | Some (_, filename, _) ->
          let rec count_size size =
            match%lwt Dream.upload_part request with
            | None -> receive ((filename, size)::file_sizes)
            | Some chunk -> count_size (size + String.length chunk) in
          count_size 0 in
        receive [])

let all_routes = [
  form_route;
  static_route;
  files_upload_route;
  stream_upload_route;
]

let _ =
  let required = ["port"] in
  Dream_config.load ~required ();
  Log.init ();
  Dream.run
    ~error_handler:Dream.debug_error_handler
    ~port: (Dream_config.get_int "port")
  @@ Dream.logger
  @@ Dream.router all_routes
