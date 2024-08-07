open Printf

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


(*
      curl --location 'http://localhost:8080' \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'message=le message !!'
*)
  let _form_d_reduced () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

    Dream.post "/"
      (fun request ->
        match%lwt Dream.form ~csrf:false request with
        | `Ok ["message", message] ->
          Dream.html (Printf.sprintf ">>>>%s<<<<" message)
        | _ ->
          Dream.empty `Bad_Request);

  ]



let report files =
  files
  |> List.map 
    (fun (name, content) -> 
      sprintf "file: %s length: %d" 
      (match name with Some s -> s | None -> "???")
      (String.length content))
  |> String.concat "\n"
  |> sprintf "%s\n"

let _multipart () =
  Dream.run
  @@ Dream.logger
  @@ Dream.router [

  Dream.post "upl" (fun request ->
    match%lwt Dream.multipart ~csrf:false request with
    | `Ok ["files", files] -> Dream.html (report files)
    | _ -> Dream.empty `Bad_Request);
  ]
  (* curl --location 'http://localhost:8080' --form 'files=@"file_A"' --form 'files=@"file_B"'  *)

let _ = _multipart ()