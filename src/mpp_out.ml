(***********************************************************************)
(* Meta Pre Processor, a language blender                              *)
(* (c) 2013 by Philippe Wang <philippe.wang@cl.cam.ac.uk>              *)
(* Licence : CeCILL-B                                                  *)
(* http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html         *)
(***********************************************************************)

type t = Buffer of Buffer.t | Out_channel of out_channel

let output_buffer o b = match o with
  | Buffer b' -> Buffer.add_buffer b' b
  | Out_channel oc -> Buffer.output_buffer oc b

let flush o = match o with
  | Buffer _ -> ()
  | Out_channel oc -> Pervasives.flush oc

let output_string o s = match o with
  | Buffer b -> Buffer.add_string b s
  | Out_channel oc -> Pervasives.output_string oc s

let output_char o c = match o with
  | Buffer b -> Buffer.add_char b c
  | Out_channel oc -> Pervasives.output_char oc c

let printf o fmt = 
  let contains_flush fmt =
    let s = string_of_format fmt in
    let n = String.length s in
    let rec f i =
      if i >= n - 1 then false else
        match s.[i], s.[i+1] with
          | '%', '!' -> true
          | '%',   _ -> f (i + 2)
          |   _,   _ -> f (i + 1)
    in f 0
  in
    match o with
      | Buffer b -> Printf.bprintf b fmt
      | Out_channel oc ->
          let b = Buffer.create 16 in
          let k b =
            Pervasives.output_string oc (Buffer.contents b);
            if contains_flush fmt then Pervasives.flush oc in
            Printf.kbprintf k b fmt

let output_charstream o cs =
  match o with
    | Buffer buff -> Buffer.add_string buff (Mpp_charstream.string_of_charstream cs)
    | Out_channel o -> Pervasives.output_string o (Mpp_charstream.string_of_charstream cs)
