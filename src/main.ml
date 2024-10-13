open Dream_utils
open Ags_main
open Grewlib

let ping_route = 
  Dream.post "ping" (fun _ -> Dream.html ~headers:["Content-Type", "text/plain"] "{}")

let new_project_route =
  Dream.post "newProject"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok ["project_id", project_id] ->
        let json = wrap new_project project_id in
        Log.info "<newProject> project_id=[%s] ==> %s" project_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_projects_route =
  Dream.post "getProjects"
    (fun request ->
      match%lwt Dream.body request with
      | "" -> 
        let json = wrap get_projects () in
        Log.info "<newProject> ==> %s" (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_user_projects_route =
  Dream.post "getUserProjects"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok ["user_id", user_id] ->
        let json = wrap get_user_projects user_id in
        Log.info "<getUserProjects> user_id=[%s] ==> %s" user_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let erase_project_route =
  Dream.post "eraseProject"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok ["project_id", project_id] ->
        let json = wrap erase_project project_id in
        Log.info "<eraseProject> project_id=[%s] ==> %s" project_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let rename_project_route =
  Dream.post "renameProject"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let new_project_id = List.assoc "new_project_id" param in
        let json = wrap (rename_project project_id) new_project_id in
        Log.info "<renameProject> project_id=[%s] new_project_id=[%s] ==> %s" project_id new_project_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_project_config_route =
  Dream.post "getProjectConfig"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok ["project_id", project_id] ->
        let json = wrap get_project_config project_id in
        Log.info "<getProjectConfig> project_id=[%s] ==> %s" project_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let update_project_config_route =
  Dream.post "updateProjectConfig"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let config = List.assoc "config" param in
        let json = wrap (update_project_config project_id) config in
        Log.info "<updateProjectConfig> project_id=[%s] config=[%s] ==> %s" project_id config (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let new_samples_route =
  Dream.post "newSamples"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let json = wrap (new_samples project_id) sample_ids in
        Log.info "<newSamples> project_id=[%s] sample_ids=[%s] ==> %s" project_id sample_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_samples_route =
  Dream.post "getSamples"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok ["project_id", project_id] ->
        let json = wrap get_samples project_id in
        Log.info "<getSamples> project_id=[%s] ==> %s" project_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let erase_samples_route =
  Dream.post "eraseSamples"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let json = wrap (erase_samples project_id) sample_ids in
        Log.info "<eraseSamples> project_id=[%s] sample_ids=[%s] ==> %s" project_id sample_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let rename_sample_route =
  Dream.post "renameSample"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id = List.assoc "sample_id" param in
        let new_sample_id = List.assoc "new_sample_id" param in
        let json = wrap (rename_sample project_id sample_id) new_sample_id in
        Log.info "<renameSample> project_id=[%s] sample_id=[%s] new_sample_id=[%s] ==> %s" project_id sample_id new_sample_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let erase_sentence_route =
  Dream.post "eraseSentence"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id = List.assoc "sample_id" param in
        let sent_id = List.assoc "sent_id" param in
        let json = wrap (erase_sentence project_id sample_id) sent_id in
        Log.info "<eraseSentence> project_id=[%s] sample_id=[%s] sent_id=[%s] ==> %s" project_id sample_id sent_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let erase_graphs_route =
  Dream.post "eraseGraphs"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id = List.assoc "sample_id" param in
        let sent_ids = List.assoc "sent_ids" param in
        let user_id = List.assoc "user_id" param in
        let json = wrap (erase_graphs project_id sample_id sent_ids) user_id in
        Log.info "<eraseGraphs> project_id=[%s] sample_id=[%s] sent_ids=[%s] user_id=[%s] ==> %s" project_id sample_id sent_ids user_id (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_conll_route =
  Dream.post "getConll"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id = List.assoc "sample_id" param in
        let sent_id_opt = List.assoc_opt "sent_id" param in
        let user_id_opt = List.assoc_opt "user_id" param in
        begin
          match (sent_id_opt, user_id_opt) with
          | (Some sent_id, Some user_id) ->
            let json = wrap (get_conll__user project_id sample_id sent_id) user_id in
            Log.info "<getConll#1> project_id=[%s] sample_id=[%s] sent_id=[%s] user_id=[%s] ==> %s" project_id sample_id sent_id user_id (report_status json);
            reply json
          | (Some sent_id, None) ->
            let json = wrap (get_conll__sent_id project_id sample_id) sent_id in
            Log.info "<getConll#2> project_id=[%s] sample_id=[%s] sent_id=[%s] ==> %s" project_id sample_id sent_id (report_status json);
            reply json
          | (None, None) ->
            let json = wrap (get_conll__sample project_id) sample_id in
            Log.info "<getConll#3> project_id=[%s] sample_id=[%s] ==> %s" project_id sample_id (report_status json);
            reply json
          | _ -> Dream.empty `Bad_Request
        end
      | _ -> Dream.empty `Bad_Request
    )

let get_users_route =
  Dream.post "getUsers"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id_opt = List.assoc_opt "sample_id" param in
        let sent_id_opt = List.assoc_opt "sent_id" param in
        begin
          match (sample_id_opt, sent_id_opt) with
          | (Some sample_id, Some sent_id) ->
            let json = wrap (get_users__sentence project_id sample_id) sent_id in
            Log.info "<getUsers#1> project_id=[%s] sample_id=[%s] sent_id=[%s] ==> %s" project_id sample_id sent_id (report_status json);
            reply json
          | (Some sample_id, None) ->
            let json = wrap (get_users__sample project_id) sample_id in
            Log.info "<getUsers#2> project_id=[%s] sample_id=[%s] ==> %s" project_id sample_id (report_status json);
            reply json
          | (None, None) ->
            let json = wrap get_users__project project_id in
            Log.info "<getUsers#3> project_id=[%s] ==> %s" project_id (report_status json);
            reply json
          | _ -> Dream.empty `Bad_Request
        end
      | _ -> Dream.empty `Bad_Request
    )

let get_sent_ids_route =
  Dream.post "getSentIds"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id_opt = List.assoc_opt "sample_id" param in
        begin
          match sample_id_opt with
          | Some sample_id ->
            let json = wrap (get_sent_ids__sample project_id) sample_id in
            Log.info "<getSentIds#1> project_id=[%s] sample_id=[%s] ==> %s" project_id sample_id (report_status json);
            reply json
          | None ->
            let json = wrap get_sent_ids__project project_id in
            Log.info "<getSentIds#2> project_id=[%s] ==> %s" project_id (report_status json);
            reply json
        end
      | _ -> Dream.empty `Bad_Request
    )

let save_conll_route = 
  Dream.post "saveConll"
    (fun request ->
      match%lwt stream_request request with
      | (map,[file]) ->
        let project_id = String_map.find "project_id" map in
        let sample_id = String_map.find "sample_id" map in
        let json = wrap (save_conll project_id sample_id) file in
        Log.info "<saveConll> project_id=[%s] sample_id=[%s] ==> %s" project_id sample_id (report_status json);
        reply json
      | (_,l) ->
        reply_error "<saveConll> received %d files (1 expected)" (List.length l)
    )

let insert_conll_route = 
  Dream.post "insertConll"
    (fun request ->
      match%lwt stream_request request with
      | (map,[file]) ->
        let project_id = String_map.find "project_id" map in
        let sample_id = String_map.find "sample_id" map in
        let pivot_sent_id = String_map.find "pivot_sent_id" map in
        let json = wrap (insert_conll project_id sample_id pivot_sent_id) file in
        Log.info "<insertConll> project_id=[%s] sample_id=[%s] pivot_sent_id=[%s] ==> %s" project_id sample_id pivot_sent_id (report_status json);
        reply json
      | (_,l) ->
        reply_error "<insertConll> received %d files (1 expected)" (List.length l)
    )

let save_graph_route =
  Dream.post "saveGraph"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_id = List.assoc "sample_id" param in
        let user_id = List.assoc "user_id" param in
        let conll_graph = List.assoc "conll_graph" param in
        let json = wrap (save_graph project_id sample_id user_id) conll_graph in
        Log.info "<saveGraph> project_id=[%s] sample_id=[%s] user_id=[%s] conll_graph=[%s] ==> %s"
          project_id sample_id user_id conll_graph (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let search_request_in_graphs_route =
  Dream.post "searchRequestInGraphs"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let user_ids = List.assoc "user_ids" param in
        let request = List.assoc "request" param in
        let clusters_opt = List.assoc_opt "clusters" param in

        let cluster_keys = match clusters_opt with
          | Some clusters -> Str.split (Str.regexp " *; *") clusters
          | None -> [] in

        let json = wrap (search_request_in_graphs project_id user_ids request) cluster_keys in
        Log.info "<searchRequestInGraphs> project_id=[%s] user_ids=[%s] request=[%s]%s ==> %s"
          project_id user_ids request 
          (match clusters_opt with None -> "" | Some s -> Printf.sprintf " clusters=[%s]" s)
          (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let relation_tables_route =
  Dream.post "relationTables"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let user_ids = List.assoc "user_ids" param in
        let json = wrap (relation_tables project_id sample_ids) user_ids in
        Log.info "<relationTables> project_id=[%s] sample_ids=[%s] user_ids=[%s] ==> %s"
          project_id sample_ids user_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let try_package_route =
  Dream.post "tryPackage"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let user_ids = List.assoc "user_ids" param in
        let package = List.assoc "package" param in
        let json = wrap (try_package project_id sample_ids user_ids) package in
        Log.info "<tryPackage> project_id=[%s] sample_ids=[%s] user_ids=[%s] package=[%s] ==> %s"
          project_id sample_ids user_ids package (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let export_project_route =
  Dream.post "exportProject"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let json = wrap (export_project project_id) sample_ids in
        Log.info "<exportProject> project_id=[%s] sample_ids=[%s] ==> %s"
          project_id sample_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_lexicon_route =
  Dream.post "getLexicon"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let user_ids = List.assoc "user_ids" param in
        let features = List.assoc "features" param in
        let prune = CCOption.map int_of_string (List.assoc_opt "prune" param) in
        let json = wrap (get_lexicon features ?prune project_id user_ids) sample_ids in
        Log.info "<getLexicon> project_id=[%s] sample_ids=[%s] user_ids=[%s] features=[%s]%s ==> %s"
          project_id sample_ids user_ids features
          (match prune with None -> "" | Some i -> Printf.sprintf " prune=[%d]" i)
          (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_pos_route =
  Dream.post "getPOS"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let json = wrap (get_pos project_id) sample_ids in
        Log.info "<getPOS> project_id=[%s] sample_ids=[%s] ==> %s"
          project_id sample_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )

let get_relations_route =
  Dream.post "getRelations"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let json = wrap (get_relations project_id) sample_ids in
        Log.info "<getRelations> project_id=[%s] sample_ids=[%s] ==> %s"
          project_id sample_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )
let get_features_route =
  Dream.post "getFeatures"
    (fun request ->
      match%lwt Dream.form ~csrf:false request with
      | `Ok param ->
        let project_id = List.assoc "project_id" param in
        let sample_ids = List.assoc "sample_ids" param in
        let json = wrap (get_features project_id) sample_ids in
        Log.info "<getFeatures> project_id=[%s] sample_ids=[%s] ==> %s"
          project_id sample_ids (report_status json);
        reply json
      | _ -> Dream.empty `Bad_Request
    )


let all_routes = [
  ping_route;

  new_project_route;
  get_projects_route;
  get_user_projects_route;
  erase_project_route;
  rename_project_route;

  get_project_config_route;
  update_project_config_route;

  new_samples_route;
  get_samples_route;
  erase_samples_route;
  rename_sample_route;

  erase_sentence_route;
  erase_graphs_route;
  get_conll_route;
  get_users_route;
  get_sent_ids_route;

  save_conll_route;
  insert_conll_route;
  save_graph_route;

  search_request_in_graphs_route;
  relation_tables_route;
  try_package_route;

  export_project_route;
  get_lexicon_route;

  get_pos_route;
  get_relations_route;
  get_features_route;

]

let _ =
  let required = ["port"] in
  Dream_config.load ~required ();
  Log.init ();
  let _ = 
    try Unix.mkdir (Dream_config.get_string "storage") 0o755
    with Unix.Unix_error(Unix.EEXIST, _, _) -> Ags_main.load_from_storage () in

  Dream.run
    ~error_handler:Dream.debug_error_handler
    ~port: (Dream_config.get_int "port")
  @@ Dream.logger
  @@ Dream.router all_routes
