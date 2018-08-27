(**************************************************************************)
(*                                                                        *)
(*    Copyright (c) 2017 - OCamlPro SAS                                   *)
(*                                                                        *)
(*    All rights reserved. No warranty, explicit or implicit, provided.   *)
(*                                                                        *)
(**************************************************************************)

type from =
  | From_string of string
  | From_file of string

let post = ref (fun ~data _ ->
  failwith "mini version cannot do post request")

let get = ref (fun _ ->
  failwith "mini version cannot do get request")

type key_diff =
  | DiffKeyHash of string
  | DiffKey of LiquidTypes.const

type big_map_diff_item =
  | Big_map_add of key_diff * LiquidTypes.const
  | Big_map_remove of key_diff

type big_map_diff = big_map_diff_item list

type stack_item =
  | StackConst of LiquidTypes.const
  | StackCode of int

type trace_item = {
  loc : LiquidTypes.location option;
  gas : int;
  stack : (stack_item * string option) list;
}

type trace = trace_item array

type internal_operation =
  | Reveal of string
  | Transaction of {
      amount : string;
      destination : string;
      parameters : LiquidTypes.const option;
    }
  | Origination of {
      manager: string ;
      delegate: string option ;
      script: (LiquidTypes.typed_contract * LiquidTypes.const) option ;
      spendable: bool ;
      delegatable: bool ;
      balance: string ;
    }
  | Delegation of string option

type operation = {
  source : string;
  nonce : int;
  op : internal_operation;
}

exception RequestError of int * string
exception ResponseError of string
exception RuntimeError of LiquidTypes.error * trace option
exception LocalizedError of LiquidTypes.error
exception RuntimeFailure of LiquidTypes.error * string option * trace option

module type S = sig
  type 'a t
  val run : from -> string -> string ->
    (operation list * LiquidTypes.const * big_map_diff option) t
  val run_debug : from -> string -> string ->
    (operation list * LiquidTypes.const * big_map_diff option * trace) t
  val init_storage :
    from -> string list -> LiquidTypes.const t
  val forge_deploy : ?delegatable:bool -> ?spendable:bool ->
    from -> string list -> string t
  val deploy : ?delegatable:bool -> ?spendable:bool ->
    from -> string list -> (string * (string, exn) result) t
  val get_storage : from -> string -> LiquidTypes.const t
  val forge_call : from -> string -> string -> string t
  val call : from -> string -> string -> (string * (unit, exn) result) t
  val activate : secret:string -> string t
end

module Dummy = struct

  let run _ _ _ =
    failwith "mini version cannot run"

  let run_debug _ _ _ =
    failwith "mini version cannot run debug"

  let init_storage _ _ =
    failwith "mini version cannot deploy"

  let forge_deploy ?(delegatable=false) ?(spendable=false) _ _ =
    failwith "mini version cannot deploy"

  let deploy ?(delegatable=false) ?(spendable=false) _ _ =
    failwith "mini version cannot deploy"

  let get_storage _ _ =
    failwith "mini version cannot query node"

  let forge_call _ _ _ =
    failwith "mini version cannot call"

  let call _ _ _ =
    failwith "mini version cannot call"

  let activate ~secret =
    failwith "mini version cannot activate"
end

module Async = struct include Dummy type 'a t = 'a Lwt.t end

module Sync = struct include Dummy type 'a t = 'a end
