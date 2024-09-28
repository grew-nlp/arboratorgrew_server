open Printf 
open Conll

open Grewlib

open Dream_utils
(* open Ags_utils *)

(* ================================================================================ *)
module User = struct
  type filter =
    | All
    | One of string list
    | Multi of string list

  let filter_of_json_string json_string =
    let open Yojson.Basic.Util in
    try
      match Yojson.Basic.from_string json_string with
      | `String "all" -> All
      | `Assoc ["one", json_list] -> One (json_list |> to_list |> List.map to_string)
      | `Assoc ["multi", json_list] -> Multi (json_list |> to_list |> List.map to_string)
      | _ -> raise (Error (sprintf "Invalid user_filter:%s\n" json_string))
    with 
    | Type_error _ | Yojson.Json_error _ -> 
      raise (Error (sprintf "Invalid user_filter:%s\n" json_string))
end

(* ================================================================================ *)
module Sentence = struct
  type t = Graph.t String_map.t  (* keys are user_id *)

  let empty = String_map.empty

  let is_empty = String_map.is_empty

  let add_graph user_id graph t = String_map.add user_id graph t

  let remove_graph user_id t = String_map.remove user_id t

  let get_users t =
    String_map.fold
      (fun user_id _ acc -> String_set.add user_id acc)
      t String_set.empty

  let append_tags init t =
    String_map.fold
      (fun _ graph acc ->
        let tag_list = 
          match Graph.get_meta_opt "tags" graph with
          | None -> []
          | Some s -> s |> String.split_on_char ',' |> (List.map String.trim) in
        List.fold_left
        (fun acc2 tag ->
          let old_cpt = CCOption.get_or ~default:0 (String_map.find_opt tag acc2) in
          String_map.add tag (old_cpt+1) acc2
        ) acc tag_list
      ) t init

  let find_opt = String_map.find_opt

  let fold = String_map.fold

  let map = String_map.map

  let mapi = String_map.mapi

  let most_recent t =
    fold
      (fun user_id graph acc ->
         match (Graph.get_meta_opt "timestamp" graph, acc) with
         | (None, _) -> acc
         | (Some string_ts, None) -> Some ((user_id, graph),float_of_string string_ts)
         | (Some string_new_ts, Some (old_data,old_ts)) ->
           let new_ts = float_of_string string_new_ts in
           if new_ts > old_ts
           then Some ((user_id,graph), new_ts)
           else Some (old_data, old_ts)
      ) t None |> CCOption.map fst |> fun (x : (string * Graph.t) option) -> x

  let save ~config out_ch t =
    String_map.iter
      (fun user_id graph ->
         graph
         |> Graph.set_meta "user_id" user_id
         |> Graph.to_json |> Conll.of_json |> Conll.to_string ~config
         |> Printf.fprintf out_ch "%s\n"
      ) t

  let get_one ?caller user_filter t =
    match user_filter with
    | User.Multi _ 
    | User.All ->
        raise (Error (
          sprintf "[%s] can be used only with user filters which produce at most one graph"
          (match caller with Some s -> s | None -> "Sentence.get_one")
          )
        )
    | User.One user_list ->
      let rec loop = function
      | [] -> None
      | "__last__"::_ -> most_recent t
      | user_id :: tail ->
        match String_map.find_opt user_id t with
        | None -> loop tail
        | Some graph -> Some (user_id, graph) in
      loop user_list
end
