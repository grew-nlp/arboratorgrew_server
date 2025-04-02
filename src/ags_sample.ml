open Grewlib
open Conll

open Dream_utils

open Ags_sentence

(* ================================================================================ *)
module Sample = struct
  (* the list always contains the same set as the data keys *)
  type t = {
    rev_order: string list;
    data: Sentence.t String_map.t; (* keys are sent_id *)
  }

  let empty = { rev_order = []; data = String_map.empty }

  let insert sent_id user_id graph t =
    match String_map.find_opt sent_id t.data with
    | None -> { rev_order = sent_id :: t.rev_order; data = String_map.add sent_id (Sentence.add_graph user_id graph Sentence.empty) t.data }
    | Some sent -> { t with data = String_map.add sent_id (Sentence.add_graph user_id graph sent) t.data }

  let users t =
    String_map.fold
      (fun _ sentence acc ->
        String_set.union acc (Sentence.get_users sentence)
      ) t.data String_set.empty

  let tags t =
    String_map.fold
      (fun _ sentence acc -> 
        Sentence.append_tags acc sentence)
       t.data String_map.empty

  let tree_by_user t =
    String_map.fold 
      (fun _ sentence acc -> 
        Sentence.fold
        (fun user _ acc2 -> 
          match String_map.find_opt user acc2 with
          | None -> String_map.add user 1 acc2
          | Some i -> String_map.add user (i+1) acc2
        ) sentence acc
      ) t.data String_map.empty

  type infos = {
    number_sentences: int;
    number_tokens: int;
    number_trees: int;
    users: String_set.t;
  }

  let get_infos t =
    let (number_tokens, number_trees, users) =
      String_map.fold
        (fun _ sentence (acc_tokens, acc_trees, acc_users) ->
          let users = Sentence.get_users sentence in
          let new_acc_users = String_set.union acc_users users in
           match String_set.choose_opt users with
           | None -> (acc_tokens, acc_trees, new_acc_users)
           | Some user ->
             match Sentence.find_opt user sentence with
             | None -> assert false
             | Some graph -> (acc_tokens + Graph.size graph, acc_trees + (String_set.cardinal users), new_acc_users)
        ) t.data (0,0, String_set.empty) in
    {
      number_sentences = String_map.cardinal t.data;
      number_tokens;
      number_trees;
      users;
    }

  let sent_ids t = List.rev t.rev_order

  let save ~config out_ch t =
    List.iter
      (fun sent_id ->
         Sentence.save ~config out_ch (String_map.find sent_id t.data)
      ) (List.rev t.rev_order)


  let load ~config project_dir filename = 
    let conll_corpus =
      try Conll_corpus.load ~config (Filename.concat project_dir filename)
      with Conll_error js -> error "Conll_error: %s" (Yojson.Basic.pretty_to_string js) in
    Array.fold_left
      (fun acc (_, conll) ->
        match List.assoc_opt "user_id" (Conll.get_meta conll) with
        | None -> warn "No user_id found, conll skipped"; acc
        | Some user_id ->
          match List.assoc_opt "sent_id" (Conll.get_meta conll) with
          | None -> warn "No sent_id found, conll skipped"; acc
          | Some sent_id ->
            let graph = conll |> Conll.to_json |> Graph.of_json in
            insert sent_id user_id graph acc
      ) empty (Conll_corpus.get_data conll_corpus)

  let rec list_remove_item item = function
    | [] -> []
    | h::t when h=item -> t
    | h::t -> h :: (list_remove_item item t)

  let remove_sent sent_id t =
    {
      rev_order = list_remove_item sent_id t.rev_order;
      data = String_map.remove sent_id t.data;
    }

  let remove_graph sent_id user_id t =
    let sentence = String_map.find sent_id t.data in
    let new_sentence = Sentence.remove_graph user_id sentence in
    if Sentence.is_empty new_sentence
    then remove_sent sent_id t
    else { t with data = String_map.add sent_id new_sentence t.data }

  (*  remove all trees for a given user_id *)
  let remove_user_id user_id t =
    let (new_data, removed_sent_ids) =
      String_map.fold 
        (fun sent_id sentence (acc, acc_rsi) -> 
          let new_sentence = Sentence.remove_graph user_id sentence in
          if Sentence.is_empty new_sentence
          then (acc, String_set.add sent_id acc_rsi)
          else (String_map.add sent_id new_sentence acc, acc_rsi)
        ) t.data (String_map.empty, String_set.empty) in
     let new_rev_order = List.filter (fun sent_id -> not (String_set.mem sent_id removed_sent_ids)) t.rev_order in
     { data = new_data; rev_order = new_rev_order }
  let map fct t = { t with data = String_map.map fct t.data }

  let fold_sentence fct t init =
    String_map.fold (fun sent_id sentence acc ->
        fct sent_id sentence acc
      ) t.data init


end
