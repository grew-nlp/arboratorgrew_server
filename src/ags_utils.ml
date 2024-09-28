open Dream_utils
open Grewlib

module String_set = struct
  include String_set
  let to_json t = `List (List.map (fun x -> `String x) (elements t))
end

module String_map = struct
  include String_map
  let to_json value_to_json t =
    let assoc_list = fold
      (fun key value acc ->
        (key, value_to_json value) :: acc
      ) t [] in 
     `Assoc assoc_list
end

let parse_json_string_list param_name string =
  let open Yojson.Basic.Util in
  try string |> Yojson.Basic.from_string |> to_list |> List.map to_string
  with
  | Type_error _ -> error "Ill-formed parameter `%s`. It must be a list of strings" param_name
  | Yojson.Json_error _ -> error "`%s` parameter is not a valid JSON data" param_name

let json_assoc_add (key : string) (value: Yojson.Basic.t) (json: Yojson.Basic.t) =
  match json with
  | `Assoc list -> `Assoc ((key, value) :: list)
  | _ -> error "[json_assoc_add] data is not an assoc list"

(* ================================================================================ *)
(* Utils *)
(* ================================================================================ *)
let folder_iter fct folder =
  let dh = Unix.opendir folder in
  try
    while true do
      match Unix.readdir dh with
      | "." | ".." -> ()
      | x -> fct x
    done;
    assert false
  with
  | End_of_file -> Unix.closedir dh

let folder_fold fct init folder =
  let dh = Unix.opendir folder in
  let acc = ref init in
  try
    while true do
      match Unix.readdir dh with
      | "." | ".." -> ()
      | file -> acc := fct file !acc
    done;
    assert false
  with
  | End_of_file -> Unix.closedir dh; !acc

