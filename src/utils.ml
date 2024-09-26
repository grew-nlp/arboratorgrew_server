open Printf

let report files =
  files
  |> List.map 
    (fun (name, content) -> 
      sprintf "file: %s length: %d" 
      (match name with Some s -> s | None -> "???")
      (String.length content))
  |> String.concat "\n"
  |> sprintf "%s\n"
