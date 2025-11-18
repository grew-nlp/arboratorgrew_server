open Printf
open Conll
open Grewlib

open Dream_utils

open Ags_utils
open Ags_sentence
open Ags_sample
open Ags_project
open Ags_cluster_output


(* ================================================================================ *)
(* Global storage of the corpora *)
(* ================================================================================ *)

let delay = 10 * 60               (* 10 minutes: number of seconds before a corpus is removed from memory *)
let refresh_frequency = 15 * 60   (* 15 minutes: time between each refresh (free corpuses from memory if no interaction since [delay]) *)
let time () = int_of_float (Unix.time ())

type state =
  | Disk of Project_info.t   (* storage of the infos to be able to answer to getProjects without loading *)
  | Mem of (Project.t * int) (* int is the timestamp of last interaction with the project *)

(* a [key] is a project_id *)
let (current_projects : state String_map.t ref) = ref String_map.empty

(* read project from storage directory *)
let load_project project_id =
  let storage = Dream_config.get_string "storage" in
  let project_dir = Filename.concat storage project_id in
  printf " INFO:  [load_project] project_dir=`%s`\n%!" project_dir;
  let (config_json, config) =
    let config_file = Filename.concat project_dir "config.json" in
    try
      let json = Yojson.Basic.from_file config_file in
      (json, Conll_config.of_json json)
    with
    | Sys_error _ -> (`Null, Conll_config.build "sud") (* no config file *)
    | Yojson.Json_error msg ->
      printf " WARNING: loading config file `%s`, IGNORED (project_id=`%s`, message=`%s`)" config_file project_id msg; (`Null, Conll_config.build "sud") in
  let samples =
    folder_fold
      (fun file acc -> match file with
        | filename when Filename.check_suffix filename ".json" -> acc
        | sample_id ->
          let sample = Sample.load ~config project_dir sample_id in
          String_map.add sample_id sample acc
      ) String_map.empty project_dir in
  Project.update_infos {Project.config_json; config; samples; infos=Project_info.zero }

let update_project project_id project =
  current_projects := String_map.add project_id (Mem (project, time ())) !current_projects


(* load project from disk if necessary *)
let get_project project_id =
  match String_map.find_opt project_id !current_projects with
  | None -> error "[get_project] No project named '%s'" project_id
  | Some (Disk _) ->
    let project = load_project project_id in
    update_project project_id project;
    project
  | Some (Mem (project,_)) ->
    update_project project_id project;
    project

let get_config project_id =
  let project = get_project project_id in
  project.config

(* force to free a project in mem *)
let free_project project_id =
  let storage = Dream_config.get_string "storage" in
  match String_map.find_opt project_id !current_projects with
  | None -> error "[free_project] No project named '%s'" project_id
  | Some (Disk _) -> ()
  | Some (Mem (project,_)) ->
    let project_dir = Filename.concat storage project_id in
    let infos = Project.get_infos project in
    Yojson.Basic.to_file (Filename.concat project_dir "infos.json") (Project_info.to_json infos);
    current_projects := String_map.add project_id (Disk infos) !current_projects

let free_outdated () =
  Log.start ();
  let kept_on_disk = ref 0 in
  let kept_in_mem = ref [] in
  let removed_from_mem = ref [] in

  let storage = Dream_config.get_string "storage" in
  current_projects := String_map.mapi
      (fun project_id (state : state) ->
         match state with
         | Disk s -> incr kept_on_disk; Disk s
         | Mem (project, t) ->
           let uptime = (time ()) - t in
           if uptime > delay
           then
             begin
               removed_from_mem := project_id :: !removed_from_mem;
               let project_dir = Filename.concat storage project_id in
               let infos = Project.get_infos project in
               Yojson.Basic.to_file (Filename.concat project_dir "infos.json") (Project_info.to_json infos);
               Disk infos
             end
           else
             begin
               kept_in_mem := project_id :: !kept_in_mem;
               Mem (project, t)
             end
      ) !current_projects;
  Gc.major();
  Log.info " ===[free_outdated]===> DISK:%d, MEM: %d (%s), MEM-->DISK: %d (%s)"
    !kept_on_disk
    (List.length !kept_in_mem)
    (String.concat "; " !kept_in_mem)
    (List.length !removed_from_mem)
    (String.concat "; " !removed_from_mem)

let rec refresh () =
  free_outdated ();
  Lwt_timeout.start (Lwt_timeout.create refresh_frequency (fun () -> refresh()))


(* initialize the project at starting time: project are loaded lazily *)
let load_from_storage () =
  let storage = Dream_config.get_string "storage" in
  folder_iter
    (fun project_id ->
       let project_dir = Filename.concat storage project_id in
       let infos_file = Filename.concat project_dir "infos.json" in
       let infos =
         try Yojson.Basic.from_file infos_file |> Project_info.of_json with
         | Sys_error _
         | Yojson.Json_error _ ->
           printf " WARNING: [project_id=`%s`] cannot find a correct `infos.json` file, force loading project\n%!" project_id;
           let project = load_project project_id in
           update_project project_id project;
           free_project project_id; (* force free memory and update the `infos.json` file *)
           Project.get_infos project in
       printf " INFO:  [load_from_storage] project_id=`%s`\n%!" project_id;
       current_projects := String_map.add project_id (Disk infos) !current_projects
    ) storage;
  printf " INFO:  [load_from_storage] ----- Data loading finished -----\n%!";
  refresh ()


(* ================================================================================ *)
(* general function to get info in the current data *)
(* ================================================================================ *)
let get_sample project_id sample_id =
  try
    let project = get_project project_id in
    String_map.find sample_id project.samples
  with Not_found -> error "[project: %s] No sample named '%s'" project_id sample_id

let get_sample_opt project_id sample_id =
  let project = get_project project_id in
  String_map.find_opt sample_id project.samples

let get_project_sample project_id sample_id =
  let project = get_project project_id in
  try (project.config, project, String_map.find sample_id project.samples)
  with Not_found -> error "[project: %s] No sample named '%s'" project_id sample_id

let get_sentence project_id sample_id sent_id =
  try String_map.find sent_id (get_sample project_id sample_id).Sample.data
  with Not_found -> error "[project: %s, sample:%s] No sent_id '%s'" project_id sample_id sent_id

(* ================================================================================ *)
(* general storage function in the current data *)
(* ================================================================================ *)
let save_sample project_id sample_id =
  let config = get_config project_id in
  let sample = get_sample project_id sample_id in
  let file = Filename.concat (Filename.concat (Dream_config.get_string "storage") project_id) sample_id in
  let out_ch = open_out file in
  Sample.save ~config out_ch sample;
  close_out out_ch

let safe_set_meta feat value graph =
  match Graph.get_meta_opt feat graph with
  | None -> Graph.set_meta feat value graph
  | Some v when v = value -> graph
  | Some v -> error "Inconsistent metadata `%s`: value `%s` in data is different from value `%s` in request" feat v value

let update_conll_data project_id sample_id sent_id user_id conllx =
  let (_, project, sample) = get_project_sample project_id sample_id in

  let sentence = match String_map.find_opt sent_id sample.data with
    | None -> Sentence.empty
    | Some sent -> sent in

  let graph =
    conllx |> Conll.to_json |> Graph.of_json
    |> (safe_set_meta "sent_id" sent_id)
    |> (safe_set_meta "user_id" user_id) in

  let new_sentence = Sentence.add_graph user_id graph sentence in

  let new_rev_order =
    if String_map.mem sent_id sample.data
    then sample.rev_order
    else sent_id :: sample.rev_order in
  let new_sample = {Sample.data = String_map.add sent_id new_sentence sample.data; rev_order=new_rev_order} in
  let new_project = Project.update_infos { project with samples = String_map.add sample_id new_sample project.samples } in

  (* local update *)
  update_project project_id new_project

let save_graph project_id sample_id user_id conll_graphs =
  let (config, project, sample) = get_project_sample project_id sample_id in
  let subcorpus = Conll_corpus.of_lines ~config (Str.split (Str.regexp "\n") conll_graphs) in
  let new_graphs = Conll_corpus.get_data subcorpus in
  let new_sample =
    Array.fold_left
      (fun acc (sent_id, conll) ->
        let (sentence, new_rev_order) = match String_map.find_opt sent_id acc.Sample.data with
        | None -> (Sentence.empty, sent_id :: acc.rev_order)
        | Some sent -> (sent, acc.rev_order) in
        let graph = conll |> Conll.to_json |> Graph.of_json |> (safe_set_meta "user_id" user_id) in
        let new_sentence = Sentence.add_graph user_id graph sentence in
        {Sample.data = String_map.add sent_id new_sentence acc.data; rev_order=new_rev_order}
      ) sample new_graphs in
  let new_project = Project.update_infos { project with samples = String_map.add sample_id new_sample project.samples } in
  update_project project_id new_project;
  save_sample project_id sample_id;
  `Null


let parse_meta meta =
  List.fold_left (
    fun acc l ->
      match Str.bounded_full_split (Str.regexp "# \\| = ") l 4 with
      | [Str.Delim "# "; Str.Text name; Str.Delim " = "; Str.Text value] -> (name, value) :: acc
      | _ -> acc
  ) [] meta

(* user_id is given in the ConLL *)
let save_conll project_id sample_id conll_file =
  let (config, project, sample) = get_project_sample project_id sample_id in

  let conll_corpus =
    try Conll_corpus.load ~config conll_file
    with Conll_error js -> error "Conll_error: %s" (Yojson.Basic.pretty_to_string js) in

  let new_sample = Array.fold_left (
    fun acc (sent_id, conllx) ->
      let sentence = match String_map.find_opt sent_id acc.Sample.data with
      | None -> Sentence.empty
      | Some sent -> sent in
    let graph = conllx |> Conll.to_json |> Graph.of_json in
    let user_id = 
      match Graph.get_meta_opt "user_id" graph 
      with Some x -> x 
      | _ -> error "Missing user_id with sent_id `%s`" sent_id in
    let new_sentence = Sentence.add_graph user_id graph sentence in
  
    let new_rev_order =
      if String_map.mem sent_id acc.data
      then acc.rev_order
      else sent_id :: acc.rev_order in
      {Sample.data = String_map.add sent_id new_sentence acc.data; rev_order=new_rev_order}
  ) sample (Conll_corpus.get_data conll_corpus) in
  let new_project = Project.update_infos { project with samples = String_map.add sample_id new_sample project.samples } in
  let _ = update_project project_id new_project in
  save_sample project_id sample_id;
  `Null

let rec insert_before pivot inserted_list = function
  | [] -> inserted_list
  | h::t when h = pivot -> inserted_list @ (h::t)
  | h::t -> h::(insert_before pivot inserted_list t);;

  (* user_id is given in the ConLL *)
let insert_conll project_id sample_id conll_file after_sent_id =
  let tmp_filename = (* Eliom_request_info.get_tmp_filename *) conll_file in
  let (config, project, sample) = get_project_sample project_id sample_id in
  let conll_corpus =
    try Conll_corpus.load ~config tmp_filename
    with Conll_error js -> error "Conll_error: %s" (Yojson.Basic.pretty_to_string js) in

  let (new_data, new_sent_id_list) = 
    Array.fold_left (
    fun (acc_data, acc_sent_id_list) (sent_id, conllx) ->
      let sentence = match String_map.find_opt sent_id acc_data with
      | None -> Sentence.empty
      | Some sent -> sent in
    let graph = conllx |> Conll.to_json |> Graph.of_json in
    let user_id = 
      match Graph.get_meta_opt "user_id" graph 
      with Some x -> x 
      | _ -> error "Missing user_id with sent_id `%s`" sent_id in
    let new_sentence = Sentence.add_graph user_id graph sentence in
  
    let updated_sent_id_list =
      if String_map.mem sent_id acc_data
      then acc_sent_id_list
      else sent_id :: acc_sent_id_list in
      (String_map.add sent_id new_sentence acc_data, updated_sent_id_list)
  ) (sample.data, []) (Conll_corpus.get_data conll_corpus) in
  let new_sample = {Sample.data = new_data; rev_order = insert_before after_sent_id new_sent_id_list sample.rev_order} in
  let new_project = Project.update_infos { project with samples = String_map.add sample_id new_sample project.samples } in
  let _ = update_project project_id new_project in
  save_sample project_id sample_id;
  `Null




(* ================================================================================ *)
(* project level functions *)
(* ================================================================================ *)
let new_project project_id =
  if String_map.mem project_id !current_projects
  then error "project '%s' already exists" project_id;
  update_project project_id Project.empty;
  Unix.mkdir (Filename.concat (Dream_config.get_string "storage") project_id) 0o755;
  `Null

let get_projects () =
  let project_list = 
    String_map.fold
      (fun project_id state acc ->
        let infos =
          match state with
          | Mem (project, _) -> Project.get_infos project
          | Disk i -> i in
        (json_assoc_add "name" (`String project_id) (Project_info.to_json infos)) :: acc
      ) !current_projects []
  in `List project_list

let get_user_projects user_id =
  let project_list = 
    String_map.fold
      (fun project_id state acc ->
        let infos =
          match state with
          | Mem (project, _) -> Project.get_infos project
          | Disk i -> i in
        if String_set.mem user_id infos.users
        then (json_assoc_add "name" (`String project_id) (Project_info.to_json infos)) :: acc
        else acc
      ) !current_projects []
  in `List project_list

let erase_project project_id =
  (* local update *)
  current_projects := String_map.remove project_id !current_projects;

  (* storage update *)
  FileUtil.rm ~recurse:true [(Filename.concat (Dream_config.get_string "storage") project_id)];
  `Null


let rename_project project_id new_project_id =
  if String_map.mem new_project_id !current_projects
  then error "[project: %s] already exists" new_project_id;

  (* local update *)
  let project = get_project project_id in
  current_projects := String_map.remove project_id !current_projects;
  update_project new_project_id project;

  (* storage update *)
  let storage = Dream_config.get_string "storage" in
  FileUtil.mv (Filename.concat storage project_id) (Filename.concat storage new_project_id);

  `Null

let get_project_config project_id =
  let project = get_project project_id in
  project.config_json

let update_project_config project_id json_config =
  let config_json = Yojson.Basic.from_string json_config in
  let config = Conll_config.of_json config_json in

  (* read the project with the old config *)
  let project = get_project project_id in

  let new_project = { project with config_json; config } in  
  update_project project_id new_project;

  (* force saving of all samples to modify conll data following new config *)
  let _ = 
    Project.iter (fun sample_id _ -> save_sample project_id sample_id ) new_project in

  let project_dir = Filename.concat (Dream_config.get_string "storage") project_id in
  Yojson.Basic.to_file (Filename.concat project_dir "config.json") config_json;
  `Null


(* force to resave all the sample of a project (internal use only) *)
let force_save project_id =
  let project = get_project project_id in
  let () = Project.iter (fun sample_id _ -> save_sample project_id sample_id) project in
  `Null

(* ================================================================================ *)
(* sample level functions *)
(* ================================================================================ *)
let new_samples project_id sample_ids =
  let project = get_project project_id in
  let sample_id_list = parse_json_string_list "sample_ids" sample_ids in
  let _ = (* Check for existing samples before starting creation to avoid partial handing of request *)
    match List.filter (fun sample_id -> String_map.mem sample_id project.samples) sample_id_list with
    | [] -> ()
    | l -> 
      let len = List.length l in 
      error "%d sample%s [%s] already exists in project '%s'" len (if len > 0 then "s" else "") (String.concat ", " l) project_id in
  let project_dir = Filename.concat (Dream_config.get_string "storage") project_id in
  let project_new_samples = List.fold_left
  (fun acc sample_id ->
    FileUtil.touch (Filename.concat project_dir sample_id);
    String_map.add sample_id Sample.empty acc
  ) project.samples sample_id_list in
  update_project project_id { project with samples = project_new_samples };
  `Null

let get_samples project_id =
  let project = get_project project_id in
  Project.to_json project

let erase_samples project_id sample_ids =
  let project = get_project project_id in
  let sample_id_list = parse_json_string_list "sample_ids" sample_ids in
  let new_samples = List.fold_left (fun acc sample_id -> String_map.remove sample_id acc) project.samples sample_id_list in
  let new_project = Project.update_infos { project with samples = new_samples } in
  update_project project_id new_project;
  List.iter
    (fun sample_id -> 
      FileUtil.rm [Filename.concat (Filename.concat (Dream_config.get_string "storage") project_id) sample_id]
    ) sample_id_list;
  `Null

let rename_sample project_id sample_id new_sample_id =
  let (_, project, sample) = get_project_sample project_id sample_id in
  if String_map.mem new_sample_id project.samples
  then error "[project: %s] sample %s already exists" project_id new_sample_id;
  let new_project = { project with samples = String_map.add new_sample_id sample (String_map.remove sample_id project.samples) } in

  update_project project_id new_project;

  let project_dir = Filename.concat (Dream_config.get_string "storage") project_id in
  FileUtil.mv (Filename.concat project_dir sample_id) (Filename.concat project_dir new_sample_id);

  `Null


(* ================================================================================ *)
(* sentence level functions *)
(* ================================================================================ *)
let erase_sentence project_id sample_id sent_id =
  let (_, project, sample) = get_project_sample project_id sample_id in
  let new_sample = Sample.remove_sent sent_id sample in
  let new_project = Project.update_infos { project with samples = String_map.add sample_id new_sample project.samples } in

  update_project project_id new_project;
  save_sample project_id sample_id;
  `Null


(* ================================================================================ *)
(* Graph level functions *)
(* ================================================================================ *)

let erase_graphs project_id sample_id sent_ids user_id =
  let (_, project, sample) = get_project_sample project_id sample_id in
  let new_sample = match parse_json_string_list "sent_ids" sent_ids with
   | [] -> Sample.remove_user_id user_id sample
   | sent_id_list -> List.fold_left (fun acc sent_id -> Sample.remove_graph sent_id user_id acc) sample sent_id_list in
  let new_project = Project.update_infos { project with samples = String_map.add sample_id new_sample project.samples } in
  update_project project_id new_project;
  save_sample project_id sample_id;
  `Null

(* ================================================================================ *)
let get_conll__user project_id sample_id sent_id user_id =
  let config = get_config project_id in
  let sentence = get_sentence project_id sample_id sent_id in
  match Sentence.find_opt user_id sentence with
  | None -> error "[project: %s, sample:%s, sent_id=%s] No user '%s'" project_id sample_id sent_id user_id
  | Some graph -> `String (graph |> Graph.to_json |> Conll.of_json |> Conll.to_string ~config)

let get_conll__sent_id project_id sample_id sent_id =
  let config = get_config project_id in
  let sentence = get_sentence project_id sample_id sent_id in
  `Assoc (
    Sentence.fold
      (fun user_id graph acc ->
         (user_id, `String (graph |> Graph.to_json |> Conll.of_json |> Conll.to_string ~config)) :: acc
      ) sentence []
  )

let get_conll__sample project_id sample_id =
  let sample = get_sample project_id sample_id in
  `Assoc (
    List.rev_map
      (fun sent_id ->
         (sent_id, get_conll__sent_id project_id sample_id sent_id)
      ) sample.rev_order
  )

(* ================================================================================ *)
let get_users__project project_id =
  let project = get_project project_id in
  String_set.to_json (Project.users project)

let get_users__sample project_id sample_id =
  let sample = get_sample project_id sample_id in
  String_set.to_json (Sample.users sample)

let get_users__sentence project_id sample_id sent_id =
  let sentence = get_sentence project_id sample_id sent_id in
  String_set.to_json (Sentence.get_users sentence)

(* ================================================================================ *)
let get_sent_ids__project project_id =
  let project = get_project project_id in
  `List (List.map (fun x -> `String x) (Project.sent_ids project))

let get_sent_ids__sample project_id sample_id =
  let sample = get_sample project_id sample_id in
  `List (List.map (fun x -> `String x) (Sample.sent_ids sample))

(* ================================================================================ *)
(* Search with Grew requests *)
(* ================================================================================ *)
let add_graph_in_cluster_output ~config sample_id sent_id user_id clust_keys request graph cluster_output =
  match Matching.search_request_in_graph ~config request graph with
  | [] -> cluster_output
  | matching_list ->
    let prefix = [
      ("sample_id", `String sample_id);
      ("sent_id", `String sent_id);
      ("conll", `String (graph |> Graph.to_json |> Conll.of_json |> Conll.to_string ~config));
      ("user_id", `String user_id);
    ] in
    List.fold_left
      (fun acc matching ->
         Cluster_output.insert ~config prefix clust_keys request graph matching acc
      ) cluster_output matching_list

let search_request_in_graphs project_id sample_ids user_ids string_request clust_keys =
  let config = get_config project_id in
  let project = get_project project_id in
  let request = Request.parse ~config string_request in

  let cluster_output =
    Project.fold_filter ~user_filter: (User.filter_of_json_string user_ids) ~sample_filter: (Project.sample_filter_from_json_string sample_ids)
      (fun sample_id sent_id user_id graph acc -> 
         add_graph_in_cluster_output ~config sample_id sent_id user_id clust_keys request graph acc
      ) project (Cluster_output.init clust_keys) in
  Cluster_output.to_json cluster_output

let pack ~config json_rule_list =
  let pat_cmd_list = parse_json_string_list "rules" json_rule_list in
  let rule_list = List.mapi (fun i pat_cmd -> sprintf "rule r_%d { %s }" i pat_cmd) pat_cmd_list in
  let string_pack = sprintf "package p { %s }" (String.concat "\n" rule_list) in
  let grs = Grs.parse ~config string_pack in
  grs

(* ================================================================================ *)
(* try_rules *)
(* ================================================================================ *)
let try_rules project_id sample_ids user_ids json_rule_list =
  Grewlib.set_track_impact true;
  let config = get_config project_id in
  let grs = pack ~config json_rule_list in
  let project = get_project project_id in
  let config = get_config project_id in
  let output =
    Project.fold_filter ~user_filter: (User.filter_of_json_string user_ids) ~sample_filter: (Project.sample_filter_from_json_string sample_ids)
      (fun sample_id sent_id user_id graph acc ->
         match Rewrite.onf_rewrite_opt ~config graph grs "Onf(p)" with
         | None -> acc
         | Some new_graph ->
           `Assoc [
             ("sample_id", `String sample_id);
             ("sent_id", `String sent_id);
             ("conll", `String (new_graph |> Graph.to_json |> Conll.of_json |> Conll.to_string ~config));
             ("user_id", `String user_id);
           ] :: acc
      ) project [] in
  `List output

let try_rules_old project_id ?sample_id ?user_id json_rule_list =
  let sample_ids = match sample_id with
    | None -> "[]"
    | Some id -> "[\""^id^"\"]" in
  let user_ids = match user_id with
    | None -> "[]"
    | Some id -> "[\""^id^"\"]" in
  try_rules project_id sample_ids user_ids json_rule_list

(* ================================================================================ *)
(* try_package *)
(* ================================================================================ *)
let try_package project_id sample_ids user_ids package =
  Grewlib.set_track_impact true;
  let project = get_project project_id in
  let config = get_config project_id in
  let grs = Grs.parse ~config (sprintf "package p { %s }" package) in
  let user_filter = User.filter_of_json_string user_ids in
  let _ = 
    match user_filter with 
    | One _ -> () 
    | _ -> error "The tryPackage service can be used only with user filters which return at most one graph (see https://github.com/Arborator/arborator-frontend/issues/222)" in
  let output =
    Project.fold_filter ~user_filter ~sample_filter: (Project.sample_filter_from_json_string sample_ids)
      (fun sample_id sent_id user_id graph acc ->
         match Rewrite.onf_rewrite_opt ~config graph grs "Onf(p)" with
         | None -> acc
         | Some new_graph ->
           match Graph.to_json new_graph with
           | `Assoc assoc_list -> 
             let modified_edges = CCOption.get_or ~default:(`List []) (List.assoc_opt "modified_edges" assoc_list) in
             let modified_nodes = CCOption.get_or ~default:(`List []) (List.assoc_opt "modified_nodes" assoc_list) in
             let new_assoc_list = assoc_list |> (List.remove_assoc "modified_edges") |> (List.remove_assoc "modified_nodes") in
             `Assoc [
               ("sample_id", `String sample_id);
               ("sent_id", `String sent_id);
               ("conll", `String (`Assoc new_assoc_list |> Conll.of_json |> Conll.to_string ~config));
               ("user_id", `String user_id);
               ("modified_edges", modified_edges);
               ("modified_nodes", modified_nodes);
             ] :: acc
           | _ -> error "BUG: [try_package] Graph.to_json is not an object"
      ) project [] in
  `List output

(* ================================================================================ *)
(* export_project *)
(* ================================================================================ *)
let export_project_to_tempfile project_id sample_id_list =
  let project = get_project project_id in
  let config = get_config project_id in

  (* export the most recent version of each sentences in the export_file *)
  let (export_file, out_ch) = Filename.open_temp_file "grew_" ".conll" in
  let test_sample_id sample_id = match sample_id_list with
    | [] -> true
    | l -> List.mem sample_id l in
  let _ =
    Project.fold_sentence
      (fun sample_id sent_id sentence acc ->
         if test_sample_id sample_id
         then
           match Sentence.most_recent sentence with
           | None -> acc
           | Some (_,graph) ->
             fprintf out_ch "%s\n" (graph |> Graph.to_json |> Conll.of_json |> Conll.to_string ~config);
             (`String sent_id) :: acc
         else acc
      )
      project [] in
  close_out out_ch;
  export_file

let export_project project_id sample_ids =
  let sample_id_list = parse_json_string_list "sample_ids" sample_ids in
  let temp_file = export_project_to_tempfile project_id sample_id_list in
  let base_name = Filename.basename temp_file in
  FileUtil.mv temp_file (Filename.concat (Dream_config.get_string "downloaddir") base_name);
  let url = sprintf "%s/export/%s" (Dream_config.get_string "base_url") base_name in
  `String url

(* ================================================================================ *)
(* get_lexicon *)
(* ================================================================================ *)

(** outputs the lexicon as a json data. The output is a list of objects;
    each object containts 2 fields: 
    * "feats" which value is an object associating feature_names with their value or `Null
    * a numeric field "freq" with the frequency of the corresponding values 
    Example of output:
     [
        { "feats": {"Gender": "Masc", "upos": "NOUN", "lemma": "État", "form": "États"}, "freq": 3 } ,
        { "feats": {"Gender": null, "upos": "NOUN", "lemma": "État", "form": "États" }, "freq": 1 } 
     ]
*)
let get_lexicon features ?prune project_id user_ids sample_ids =
  let feature_name_list = parse_json_string_list "features" features in
  let project = get_project project_id in
  let full_lexicon =
    Project.fold_filter
      ~user_filter: (User.filter_of_json_string user_ids)
      ~sample_filter: (Project.sample_filter_from_json_string sample_ids)
      (fun _ _ _ graph acc -> 
         Graph.append_in_ag_lex feature_name_list graph acc
      ) project Clustered.empty in
  let lexicon = match prune with
    | Some d -> Clustered.prune_unambiguous d full_lexicon
    | None -> full_lexicon in
  let json_lex_entry_list = 
    Clustered.fold 
    (fun value_opt_list freq acc ->
      let feats = 
        List.map2 
          (fun feature_name value_opt -> 
            (feature_name, CCOption.map_or ~default:`Null (fun x -> `String x) value_opt)
          ) feature_name_list value_opt_list in
      `Assoc [
        ("feats", `Assoc feats);
        ("freq", `Int freq)
      ] :: acc
    ) lexicon [] in
  `List json_lex_entry_list


let string_set_collect fct sample_ids project_id =
  let sample_id_list = 
    match parse_json_string_list "sample_ids" sample_ids with
    | [] -> Project.sample_id_list (get_project project_id)
    | l -> l in
  let string_set = 
    List.fold_left
      (fun acc sample_id ->
        match get_sample_opt project_id sample_id with
        | None -> acc
        | Some sample ->
          Sample.fold_sentence
            (fun _ sentence acc2 ->
              Sentence.fold
                (fun _ graph acc3 -> String_set.union (fct graph) acc3
                ) sentence acc2
            ) sample acc
      ) String_set.empty sample_id_list in
  String_set.elements string_set

let string_list_to_json l = `List (List.map (fun x -> `String x) l)

let get_pos sample_ids project_id =
  string_set_collect (Graph.get_feature_values "upos") sample_ids project_id
  |> string_list_to_json

let get_relations sample_ids project_id =
  let config = get_config project_id in
  string_set_collect (Graph.get_relations ~config) sample_ids project_id
  |> string_list_to_json

let decode_feat_name s = Str.global_replace (Str.regexp "__\\([0-9a-z]+\\)$") "[\\1]" s
let get_features sample_ids project_id =
  let config = get_config project_id in
  let full_list = string_set_collect (fun g -> String_set.map decode_feat_name (Graph.get_features g)) sample_ids project_id in
  let filtered_list = List.filter (fun x -> not (List.mem x ["upos"; "xpos"; "form"; "lemma"; "textform"; "wordform"])) full_list in
  let (feats, misc) = List.partition (Conll_config.is_in_FEATS config) filtered_list in
  `Assoc [
    "FEATS", string_list_to_json feats;
    "MISC", string_list_to_json misc;
  ]

let add_graph_in_relation_tables ~config graph relation_tables =
  let request = Request.parse ~config "pattern { e: GOV -> DEP}" in
  List.fold_left
    (fun acc matching ->
      let get_key_opt string_key =
        let clust_key = Request.parse_cluster_item ~config request string_key in 
        Matching.get_clust_value_opt ~config clust_key request graph matching in
      let gov = match get_key_opt "GOV.upos" with
        | Some pos -> pos | None -> "_" in
      let dep = match (get_key_opt "DEP.ExtPos", get_key_opt "DEP.upos") with
        | (Some pos, _) | (None, Some pos) -> pos | _ -> "_" in
      let lab = match get_key_opt "e.label" with
        | Some l -> l | None -> "_" in
      let map1 = match String_map.find_opt lab acc with None -> String_map.empty | Some l -> l in
      let map2 = match String_map.find_opt gov map1 with None -> String_map.empty | Some l -> l in
      let count = match String_map.find_opt dep map2 with None -> 0 | Some i -> i in
      String_map.add lab (
        String_map.add gov (
          String_map.add dep (
            count+1
          ) map2
        ) map1
      ) acc
    ) relation_tables (Matching.search_request_in_graph ~config request graph)

let relation_tables project_id sample_ids user_ids =
  let project = get_project project_id in
  let config = get_config project_id in
  let map = 
    Project.fold_filter ~user_filter: (User.filter_of_json_string user_ids) ~sample_filter: (Project.sample_filter_from_json_string sample_ids)
      (fun _ _ _ graph acc -> 
        add_graph_in_relation_tables ~config graph acc
      ) project String_map.empty in
  let json = 
    `Assoc
      (String_map.fold
        (fun lab map1 acc1 ->
          let json1 =
            `Assoc 
              (String_map.fold
                (fun gov map2 acc2 ->
                  let json2 =
                    `Assoc 
                      (String_map.fold
                        (fun dep count acc3 ->
                          (dep, `Int count ) :: acc3
                        ) map2 []
                      ) in
                  (gov, json2 ) :: acc2
                ) map1 []
              ) in
          (lab, json1 ) :: acc1
        ) map []
      ) in
  json



