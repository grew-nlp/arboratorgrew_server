(lang dune 3.16)

(name arboratorgrew_server)

(generate_opam_files true)

(source
 (github grew-nlp/arboratorgrew_server))

(authors "Bruno Guillaume")

(maintainers "Bruno Guillaume")

(license LICENSE)

(documentation https://grew.fr/usage/grew_server/)

(package
 (name arboratorgrew_server)
 (synopsis "An API for the Arborator-Grew annotation tool")
 (depends 
  ocaml
  dune
  yojson
  dream
  ANSITerminal
  conll
  (grewlib ( >= "1.19.0" ))
 )
 (tags
  ("NLP" "Annotation tool" "Grew")
 )
)

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
