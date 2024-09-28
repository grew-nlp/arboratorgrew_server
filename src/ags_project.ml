open Conll

open Ags_utils
open Ags_sample
open Ags_sentence

(* ================================================================================ *)
module Project_info = struct
  type t = {
    number_samples: int;
    number_sentences: int;
    number_tokens: int;
    number_trees: int;
    users: String_set.t;
  }

  let zero = {
    number_samples = 0;
    number_sentences = 0;
    number_tokens = 0;
    number_trees = 0;
    users = String_set.empty;
  }

  let to_json t = 
    `Assoc [
      ("number_samples", `Int t.number_samples);
      ("number_sentences", `Int t.number_sentences);
      ("number_tokens", `Int t.number_tokens);
      ("number_trees", `Int t.number_trees);
      ("users", `List (List.map (fun user_id -> `String user_id) (String_set.elements t.users)));
    ]

  let of_json json =
    let open Yojson.Basic.Util in
    {  number_samples = json |> member "number_samples" |> to_int;
       number_sentences= json |> member "number_sentences" |> to_int;
       number_tokens= json |> member "number_tokens" |> to_int;
       number_trees= json |> member "number_trees" |> to_int;
       users = json |> member "users" |> to_list |> (List.map to_string) |> String_set.of_list;
    }
end (* module Project_info *)
(* ================================================================================ *)
module Project = struct

  (* a [key] is a sample_id *)
  type t = {
    samples: Sample.t String_map.t;
    config_json: Yojson.Basic.t;
    config: Conll_config.t;
    infos: Project_info.t;
  }

  let empty = { 
    samples = String_map.empty; 
    config_json = `Null;
    config = Conll_config.build "sud";
    infos = Project_info.zero
  }

  let get_infos t = t.infos
  let update_infos t =
    let (number_sentences, number_tokens, number_trees, users) =
      String_map.fold
        (fun _ sample (acc_sentences, acc_tokens, acc_trees, acc_users) ->
          let sample_infos = Sample.get_infos sample in
          (
            acc_sentences + sample_infos.number_sentences,
            acc_tokens + sample_infos.number_tokens,
            acc_trees + sample_infos.number_trees,
            String_set.union acc_users sample_infos.users
          )
        ) t.samples (0,0,0,String_set.empty) in
    { t with infos = {
        number_samples = String_map.cardinal t.samples;
        number_sentences;
        number_tokens ;
        number_trees;
        users;
      }
    }

  let iter fct t = String_map.iter fct t.samples

  let map fct t  = update_infos { t with samples = String_map.map fct t.samples }

  let mapi fct t = update_infos { t with samples = String_map.mapi fct t.samples }

  let sample_id_list t = 
    String_map.fold 
      (fun sample_id _ acc -> 
         sample_id :: acc
      ) t.samples []

  let fold_sentence fct t init =
    String_map.fold (fun sample_id sample acc ->
        String_map.fold (fun sent_id sentence acc2 ->
            fct sample_id sent_id sentence acc2
          ) sample.Sample.data acc
      ) t.samples init

  (* sample_filter --> None = no filter; Some l = keep only sample_id listed in l *)
  let sample_filter_from_json_string sample_ids =
    match parse_json_string_list "sample_ids" sample_ids with
    | [] -> None
    | l -> Some l

  let fold_filter ?(user_filter=User.All) ?(sample_filter=None) fct t init =
    String_map.fold 
      (fun sample_id sample acc ->
        match sample_filter with
        | Some l when not (List.mem sample_id l) -> acc
        | _ -> (* both cases: sample_filter is None or Some l with sample_id in l *)
          String_map.fold
            (fun sent_id sentence acc2 ->
              match user_filter with
              | All ->
                String_map.fold
                  (fun user_id graph acc3 ->
                    fct sample_id sent_id user_id graph acc3
                  ) sentence acc2
              | Multi user_list -> 
                String_map.fold 
                  (fun user_id graph acc3 ->
                    if List.mem user_id user_list
                    then fct sample_id sent_id user_id graph acc3
                    else acc3
                  ) sentence acc2
              | One user_list ->
                let rec loop = function
                  | [] -> acc2
                  | "__last__"::_ ->
                    begin
                      match Sentence.most_recent sentence with
                      | None -> acc2 (* NB: only if sentence has no user! *)
                      | Some (user_id,graph) -> fct sample_id sent_id user_id graph acc2
                    end
                  | user_id :: tail ->
                    match String_map.find_opt user_id sentence with
                    | None -> loop tail
                    | Some graph -> fct sample_id sent_id user_id graph acc2 in
                loop user_list
            ) sample.Sample.data acc
      ) t.samples init

  let to_json project =
    `List
      (String_map.fold
        (fun sample_id sample acc ->
          let sample_infos = Sample.get_infos sample in
            (`Assoc [
                ("name", (`String sample_id));
                ("number_sentences", `Int sample_infos.number_sentences);
                ("number_tokens", `Int sample_infos.number_tokens);
                ("number_trees", `Int sample_infos.number_trees);
                ("tree_by_user", String_map.to_json (fun i -> `Int i) (Sample.tree_by_user sample));
                ("tags", String_map.to_json (fun i -> `Int i) (Sample.tags sample));
              ]
            ) :: acc
        ) project.samples []
      )

  let users t =
    String_map.fold
      (fun _ sample acc -> String_set.union acc (Sample.users sample)
      ) t.samples String_set.empty

  let sent_ids t =
    String_map.fold
      (fun _ sample acc -> (Sample.sent_ids sample) @ acc
      ) t.samples []
end

