val alphas   = ["datatype", "type", "val"]
val symbols  = ["(", ")", "*", "="]
val comments = ["(*", "*)"]

datatype token = Id of string | Key of string

fun member (x:string, l) = List.exists (fn y => x = y) l

fun alphaTok a = if member (a, alphas)
                 then Key(a)
                 else Id(a)

(* Scanning of symbolic keyword *)
fun symbolic (sy, ss) =
  case Substring.getc ss of
       NONE          => (Key sy, ss)
     | SOME (c, ss1) =>
         if member(sy, symbols) orelse not (Char.isPunct c)
         then (Key sy, ss)
         else symbolic (sy ^ String.str c, ss1)

(* Scanning a substring into a list of tokens *)
fun scanning (toks, ss) =
  case Substring.getc ss of
       NONE => rev toks
     | SOME (c, ss1) =>
         if Char.isAlphaNum c
         then (* identifier or keyword *)
              let val (id, ss2) = Substring.splitl Char.isAlphaNum ss
                  val tok       = alphaTok (Substring.string id)
              in scanning (tok::toks, ss2)
              end
         else if Char.isPunct c
         then (* special symbol *)
              let val (tok, ss2) = symbolic (String.str c, ss1)
              in scanning (tok::toks, ss2)
              end
         else (* ignore spaces, line breaks, control characters *)
              scanning (toks, Substring.dropl (not o Char.isGraph) ss)

fun scan a = scanning([], Substring.all a)
