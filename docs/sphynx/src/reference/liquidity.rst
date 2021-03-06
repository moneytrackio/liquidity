


Liquidity Reference
===================

Contract Format
---------------

All the contracts have the following form::

 [%%version 0.3]
 
 <... local declarations ...>
 
 let%init storage
     (x : TYPE)
     (x : TYPE)
     ... =
     BODY
 
 let%entry main
     (parameter : TYPE)
     (storage : TYPE) =
     BODY


The ``version`` statement tells the compiler in which version of
Liquidity the contract is written. The compiler will reject any
contract that has a version that it does not understand (too old, more
recent). We expect to reach version 1.0 at the launch of the Tezos
network.

The ``main`` function is the default entry point for the contract.
``let%entry`` is the construct used to declare entry points (there is
currently only one entry point, but there will be probably more in the
future).  The declaration takes two parameters with names
``parameter``, ``storage``, the arguments to the function. Their types must
always be specified. The return type of the function must also be
specified by a type annotation.

A contract always returns a pair ``(operations, storage)``, where
``operations`` is a list of internal operations to perform after
exectution of the contract, and ``storage`` is the final state of the
contract after the call. The type of the pair must match the type of a
pair where the first component is a list of opertations and the second
is the type of the argument ``storage`` of ``main``.

``<... local declarations ...>`` is an optional set of optional type and
function declarations. Type declarations can be used to define records
and variants (sum-types), described later in this documentation.

An optional initial storage or storage initializer can be given with
``let%init storage``. When deploying a Liquidity contract, if the
storage is not constant it is evaluated in the prevalidation context.

Basic Types and Values
----------------------

Types in Liquidity are monomorphic. They are all inherited from
Michelson, except for algebraic data types and records, that are
translated to Michelson types.

Basic Types
~~~~~~~~~~~

The built-in base types are:

- ``unit``: whose only constructor is ``()``
- ``bool``: Booleans
- ``int``: Unbounded integers
- ``nat``: Unbounded naturals (positive integers)
- ``tez``: The type of amounts
- ``string``: character strings
- ``bytes``: bytes sequences
- ``timestamp``: dates and timestamps
- ``key``: cryptographic keys
- ``key_hash``: hashes of cryptographic keys
- ``signature``: cryptographic signatures
- ``operation``: type of operations, can only be constructed
- ``address``: abstract type of contract addresses

Composite Types
~~~~~~~~~~~~~~~
  
Types can be composed using the following type operators:

- tuples: noted ``t1 * t2``, ``t1 * t2 * t3``, etc.
- functions: ``'a -> 'b`` is the type of functions from ``'a`` to
  ``'b``, equivalent to ``('a, 'b) lambda``.

and the following predefined combinators:
  
- lists: ``'a list`` is the type of lists of elements in ``'a``
- sets: ``'a set`` is the type of sets of elements in ``'a`` (``'a`` must
   be a comparable type)
- maps: ``('key, 'val) map`` is the type of maps whose keys are of type
  ``'key``, a comparable type, and values of type ``'val``;
- big maps: ``('key, 'val) big_map`` is the type of lazily
  deserialized maps whose keys are of type ``'key`` (a comparable
  type) and values of type ``'val``;
- contracts: ``'a contract`` for contracts whose parameter is of type ``'a``;
  
and the predefined algebraic data types:

- option type: ``'a option = None | Some of 'a``
- variant type: ``('a, 'b) variant = Left of 'a | Right of 'b``

Record and variant types must be declared beforehand and are referred
to by their names.


Constants Values
~~~~~~~~~~~~~~~~

The unique constructor of type ``unit`` is ``()``.

The two Booleans (``bool``) constants are:

* ``true``
* ``false``

As in Michelson, there are different types of integers:

* ``int`` : an unbounded integer, positive or negative, simply written ``0``,``1``,``2``,``-1``,``-2``,...
* ``nat`` : an unbounded positive integer, written either with a ``p`` suffix (``0p``, ``12p``, etc.) or as an integer with a type coercion ( ``(0 : nat)`` ).
* ``tez`` : an unbounded positive float of Tezzies, written either with a ``tz`` suffix (``1.00tz``, etc.) or as a string with type coercion (``("1.00" : tez)``).

Strings (``string``) are delimited by the characters ``"`` and ``"``.

Bytes (``bytes``) are sequences of hexadecimal pairs preceeded by ``0x``, for
instance:

* ``0x``
* ``0xabcdef``

Timestamps (``timestamp``) are written in ISO 8601 format, like in Michelson:

* ``2015-12-01T10:01:00+01:00``

Keys, key hashes and signatures are base58-check encoded, the same as in Michelson:

* ``tz1YLtLqD1fWHthSVHPD116oYvsd4PTAHUoc`` is a key hash (``key_hash``)
* ``edpkuit3FiCUhd6pmqf9ztUTdUs1isMTbF9RBGfwKk1ZrdTmeP9ypN`` is a public
  key (``key``)
*
  ``edsigedsigthTzJ8X7MPmNeEwybRAvdxS1pupqcM5Mk4uCuyZAe7uEk68YpuGDeViW8wSXMr
  Ci5CwoNgqs8V2w8ayB5dMJzrYCHhD8C7`` is a signature (``signature``)

There are also three types of collections: lists, sets and
maps. Constants collections can be created directly:

* Lists: ``["x"; "y"]`` for a ``string list``;
* Sets: ``Set [1; 2; 3; 4]`` for an ``int set``;
* Maps: ``Map [1, "x"; 2, "y"; 3, "z"]`` for a ``(int, string) map``;
* Big maps: ``BigMap [1, "x"; 2, "y"; 3, "z"]`` for a ``(int, string) big_map``

In the case of an empty collection, whose type cannot be inferred, the type must be specified:

* Lists: ``([] : int list)``
* Sets: ``(Set : int set)``
* Maps: ``(Map : (int, string) map)``
* Big maps: ``(BigMap : (int, string) big_map)``

Options (``option``) can be defined with:

* An empty option: ``(None : int option)``
* A valued option: ``Some 3``

Variants (``variant``) can be defined with:

* Left alternative: ``Left "hello"``
* Right alternative: ``Right 3``

for a ``(string, int) variant``.

The ``variant`` type is not supposed to be used by programmers, who
can defined their own algebraic data types. Instead, ``variant`` is
used when decompiling Michelson code.

It is also possible to coerce some constants between their inferred
type and another compatible type, using the notation
``( CONSTANT : NEWTYPE )``:

* A ``string`` can be coerced to ``tez`` (the string must contain an
  integer in mutez à la Michelson), ``timestamp``, ``key``,
  ``address``, ``_ contract``, ``key_hash`` and ``signature``.
* A ``bytes`` can be coerced to ``address``, ``_ contract``, ``key``,
   ``key_hash`` and ``signature``.
* An ``address`` can be coerced to ``_ contract``.
* A ``_ contract`` can be coerced to ``address``.
* A ``key_hash`` can be coerced to ``unit contract`` and ``address``.


Predefined Primitives
---------------------

There are two kinds of primitives in the language:

* **Prefix primitives** are used by putting the primitive before the
  arguments: ``prim x y z``. All alphanumerical primitives are prefix
  primitives, except ``lor``, ``lxor``, ``mod``, ``land``, ``lsl``,
  ``lsr`` and ``asr``.
* **Infix primitves** are used by putting the primitive between the
  arguments: ``x prim y``. Infix primitives are always operators
  (``+``, ``-``, etc.).

When the type of a primitive is specified, we extend the notation for
functions like this:

* ``TYPE_ARG -> TYPE_RESULT`` for a primitive with one argument
* ``TYPE_ARG1 -> TYPE_ARG2 -> TYPE_RESULT`` for a primitive with two arguments

Whereas functions can only take one argument in Liquidity/Michelson
(possibly a tuple), primitives can take multiple arguments.

Comparison between values
~~~~~~~~~~~~~~~~~~~~~~~~~

All the values are not comparable. Only two values of the following
types can be compared with each other:

* ``bool``
* ``int``
* ``nat``
* ``tez``
* ``string``
* ``bytes``
* ``timestamp``
* ``key_hash``
* ``address``

The following comparison operators are available:

* ``=`` : equal
* ``<>`` : not-equal
* ``<`` : strictly less
* ``<=`` : less or equal
* ``>`` : strictly more
* ``>=`` : more or equal

There is also a function ``compare x y`` to compare two values and return
an integer, as follows:

* returns 0 if ``x`` and ``y`` are equal
* returns a strictly positive integer if ``x > y``
* returns a strictly negative integer if ``x < y``

The ``Current`` module
~~~~~~~~~~~~~~~~~~~~~~

* ``Current.balance: unit -> tez``: returns the balance of the current
  contract. The balance contains the amount of tez that was sent by
  the current operation. It is translated to ``BALANCE`` in Michelson.

  Example::

    let bal = Current.balance() in
    ...
    
* ``Current.time: unit -> timestamp``: returns the timestamp of the
  block in which the transaction is included. This value is chosen by
  the baker that is including the transaction, so it should not be
  used as a reliable source of alea.  It is translated to ``NOW`` in
  Michelson.

  Example::
    
    let now = Current.time () in
    ...
    
* ``Current.amount: unit -> tez``: returns the amount of tez
  transferred by the current operation (standard or internal
  transaction). It is translated to ``AMOUNT`` in Michelson.

  Example::

    let received = Current.amount() in
    ...
    
* ``Current.gas: unit -> nat``: returns the amount of gas available to
  execute the rest of the transaction. It is translated to
  ``STEPS_TO_QUOTA`` in Michelson.

  Example::

    let remaining_gas = Current.gas () in
    if remaining_gas < 1000p then
      Current.failwith ("not enough gas", remaining_gas);
    ...
  
* ``Current.source: unit -> address``: returns the address that
  initiated the current transaction in the blockchain. It is the same
  one for all the operations in the transaction, standard and
  internal. It is the address that paid the fees and storage cost, and
  signed the operation on the blockchain. It is translated to
  ``SOURCE`` in Michelson.

  Example::

    let addr = Current.source () in
    ...
    
* ``Current.sender: unit -> address``: returns the address that
  initiated the current operation. It is the same as the source for
  the toplevel operation, but it is the originating contract for
  internal operations. It is translated to ``SENDER`` in Michelson.

  Example::

    let addr = Current.sender () in
    ...
    
* ``failwith`` or ``Current.failwith: 'a -> 'b``: makes the current
  transaction and all its internal transactions fail. No modification
  is done to the context. The argument can be any value (often a
  string and some argument), the system will display it to explain why
  the transaction failed.

  Example::

    let remaining_gas = Current.gas () in
    if remaining_gas < 1000p then
      Current.failwith ("not enough gas", remaining_gas);
    ...
  
Operations on tuples
~~~~~~~~~~~~~~~~~~~~

* ``get t n``, ``Array.get t n`` and ``t.(n)`` where ``n`` is a
  constant positive-or-nul int: returns the ``n``-th element of the
  tuple ``t``. Tuples are translated to Michelson by pairing on the
  right, i.e. ``(a,b,c,d)`` becomes ``(a, (b, (c,d)))``. In this
  example, ``a`` is the ``0``-th element.

  Example::

    let x = (1,2,3,4) in
    let car = x.(0) in
    let cdr = x.(1) in
    if car <> 1 || car <> 2 then Current.failwith "Error !";
  
* ``set t n x``, ``Array.set t n x`` and ``t.(n) <- x`` where ``n`` is
  constant positive-or-nul int: returns the tuple where the ``n``-th element
  has been replaced by ``x``.

  Example::

    let x = (1,2,3,4) in
    let x0 = x.(0) <- 10 in
    let x1 = x0.(1) <- 11 in
    if x1 <> (10,11,3,4) then Current.failwith "Error !";

  
Operations on numeric values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* ``+``: Addition. With the following types:
  
  * ``tez -> tez -> tez``
  * ``nat -> nat -> nat``
  * ``int|nat -> int|nat -> int``
  * ``timestamp -> int|nat -> timestamp``
  * ``int|nat -> timestamp -> timestamp``
    
    It is translated to ``ADD`` in Michelson.
    
* ``-``: Substraction. With the following types:
  
  * ``tez -> tez -> tez``
  * ``int|nat -> int|nat -> int``
  * ``timestamp -> int|nat -> timestamp``
  * ``timestamp -> timestamp -> int``
  * ``int|nat -> int`` (negation)
  
    It is translated to ``SUB`` in Michelson.

* ``*``: Multiplication. With the following types:

  * ``nat -> tez -> tez``
  * ``tez -> nat -> tez``
  * ``nat -> nat -> nat``
  * ``nat|int -> nat|int -> int``

    It is translated to ``MUL`` in Michelson.

    Example::

      (* conversion from nat to tez *)
      let v = 1000p in
      let amount = v * 1tz in
      ...

* ``/``: Euclidian division. With the following types:

  * ``nat -> nat -> ( nat * nat ) option``
  * ``int|nat -> int|nat -> ( int *  nat ) option``
  * ``tez -> nat -> ( tez * tez ) option``
  * ``tez -> tez -> ( nat * tez ) option``
  
    It is translated to ``EDIV`` in Michelson.

    Example::

      (* conversion from tez to nat *)
      let v = 1000tz in
      let (nat, rem_tez) = v / 1tz in
      ...
    
* ``~-``: Negation. Type: ``int|nat -> int``
  
    It is translated to ``NEG`` in Michelson.
  
* ``lor``, ``or`` and ``||``: OR with the following types:

  * ``bool -> bool -> bool``
  * ``nat -> nat -> nat``
  
    It is translated to ``OR`` in Michelson.
    
* ``&``, ``land`` and ``&&``: AND with the following types:

  * ``bool -> bool -> bool``
  * ``nat|int -> nat -> nat``
  
    It is translated to ``AND`` in Michelson.

* ``lxor``, ``xor``: Exclusive OR with the following types:

  * ``bool -> bool -> bool``
  * ``nat -> nat -> nat``
  
    It is translated to ``XOR`` in Michelson.
    
* ``not``: NOT

  * ``bool -> bool``
  * ``nat|int -> int`` (two-complement with sign negation)

    It is translated to ``NOT`` in Michelson.

* ``abs``: Absolute value. Type ``int -> int``

    It is translated to ``ABS`` in Michelson.

* ``is_nat``: Maybe positive. Type ``int -> nat option``. It is
  translated to ``IS_NAT`` in Michelson.

    Instead of using ``is_nat``, it is recommended to use a specific form
    of pattern matching::

      match%nat x with
      | Plus x -> ...
      | Minus x -> ...

* ``int``: To integer. Type ``nat -> int``

    It is translated to ``INT`` in Michelson.

* ``>>`` and ``lsr`` : Logical shift right. Type ``nat -> nat -> nat``

    It is translated to ``LSR`` in Michelson.

* ``<<`` and ``lsl`` : Logical shift left. Type ``nat -> nat -> nat``

    It is translated to ``LSL`` in Michelson.


Operations on contracts
~~~~~~~~~~~~~~~~~~~~~~~

* ``Contract.call: 'a contract -> tez -> 'a -> operation``. Forge an
  internal transaction. It is translated to ``TRANSFER_TOKENS`` in
  Michelson.

  Example::

    let contract =  (tz1... : unit contract) in
    let op = Contract.call contract 1000tz () in
    ...
    ([op], storage)
  
* ``Account.create: key_hash -> key_hash option -> bool -> tez ->
  operation * address``. Forge an operation to create a new
  (originated) account and returns its address. It is translated to
  ``CREATE_ACCOUNT`` in Michelson.

  Example::

    let not_delegatable = false in
    let (op, addr) =
      Account.create manager (Some delegate) not_delegatable 100tz
    in
    ...
    ([op], storage)
  
* ``Account.default: key_hash -> unit contract``. Returns the contract
  associated to the given ``key_hash``. Since this contract is not
  originated, it cannot contains code, so transfers to it cannot
  fail. It is translated to ``IMPLICIT_ACCOUNT`` in Michelson.

  Example::

    let key = edpk... in
    let key_hash = Crypto.hash_key key in
    let contract = Account.default key_hash in
    ...
  
* ``Contract.set_delegate: key_hash option -> operation``. Forge a
  delegation operation for the current contract. A ``None`` argument
  means that the contract should have no delegate (it falls back to
  its manager). The delegation operation will only be executed in an
  internal operation if it is returned at the end of the ``%entry``
  function. It is translated to ``SET_DELEGATE`` in Michelson.

  Example::

    let op1 = Contract.set_delegate (Some tz1...) in
    let op2 = Contract.set_delegate None in
    ...
    ([op1;op2], storage)
  
* ``Contract.address: _ contract -> address`` . Returns the address of
  a contract. It is translated to ``ADDRESS`` in Michelson.

  Example::

    let addr = Contract.address (Contract.self ()) in
    let map = Map.add addr contract map in
    ...
  
* ``Contract.at: address -> 'a contract option``. Returns the contract
  associated with the address and type annotation, if any. Must be
  annotated with the type of the contract. It is translated to
  ``CREATE_CONTRACT`` in Michelson.

  Example::

    match (Contract.at addr : (bool contract) option) with
    | None -> failwith ("Cannot recover bool contract from:", addr)
    | Some contract -> ...
  
    
* ``Contract.self: unit -> 'a contract``. Returns the current
  executing contract. It is translated to ``SELF`` in Michelson.

  Example::

    let contract = Contract.self () in
    ...
  
* ``Contract.create: key_hash -> key_hash option -> bool -> bool ->
  tez -> 'storage -> ('param -> 'storage -> operation list * 'storage)
  -> (operation, address)``. Forge an operation to originate a
  contract with code. The contract is only created when the operation
  is executed, so it must be returned by the transaction. Note that
  the code must be specified as an inline function with two arguments
  ``parameter`` and ``storage`` with type annotatinons. It is
  translated to ``CREATE_CONTRACT`` in Michelson.


  Example::

    let delegatable = true in
    let spendable = false in
    let contract_storage = (10tz,"Hello") in
    let (op, addr) =
       Contract.create manager (Some delegate) delegatable spendable
         10tz contract_storage
         (fun (parameter:string) (storage: tez * string) ->
         ...)
    in

    (* THIS WILL FAIL UNTIL THE OPERATION IS EXECUTED *)
    let new_contract = (Contract.at addr : string contract option) in
    ...
    ( [op], storage )
    
Cryptographic operations
~~~~~~~~~~~~~~~~~~~~~~~~
              
* ``Crypto.blake2b: bytes -> bytes``. Computes the cryptographic hash of
  a bytes with the cryptographic Blake2b function. It is translated to
  ``BLAKE2B`` in Michelson.

  Example::

    let hash = Crypto.blake2b (Bytes.pack map) in
    ...
  
* ``Crypto.sha256: bytes -> bytes``. Computes the cryptographic hash
  of a bytes with the cryptographic Sha256 function. It is translated
  to ``SHA256`` in Michelson.

  Example::

    let hash = Crypto.sha256 (Bytes.pack map) in
    ...
  
* ``Crypto.sha512: bytes -> bytes``. Computes the cryptographic hash of
  a bytes with the cryptographic Sha512 function. It is translated to ``SHA512`` in Michelson.

  Example::

    let hash = Crypto.sha512 (Bytes.pack map) in
    ...

  
* ``Crypto.hash_key: key -> key_hash``. Hash a public key and encode
  the hash in B58check. It is translated to ``HASH_KEY`` in Michelson.

  Example::

    let key_hash = Crypto.hash_key edpk1234... in
    let contract = Account.default key_hash in
    ...

  
* ``Crypto.check: key -> signature -> bytes -> bool``. Check that the
  signature corresponds to signing the sequence of bytes with the
  public key. It is translated to ``CHECK_SIGNATURE`` in Michelson.

  Example::

    let bytes = Crypto.blake2b (Bytes.pack param) in
    if not (Crypto.check key signature bytes) then
      failwith "You are not allowed to do that";
    ...
  
Operations on bytes
~~~~~~~~~~~~~~~~~~~
              
* ``Bytes.pack: 'a -> bytes``. Serialize any data to a binary
  representation in a sequence of bytes. It is translated to ``PACK``
  in Michelson.

  Example::

    let s = Bytes.pack [1;2;3;4;5] in
    let hash = Crypto.sha256 s in
    ...
  
* ``Bytes.unpack: bytes -> 'a option``. Deserialize a sequence of
  bytes to a value from which it was serialized. The expression must
  be annotated with the (option) type that it should return. It is
  translated to ``UNPACK`` in Michelson.

  Example::

    let s = Bytes.pack (1,2,3,4) in
    let t = (Bytes.unpack s : (int * int * int * int) option) in
    if t.(0) <> 1 then failwith "bad unpack";
    ...
  
* ``Bytes.length`` or ``Bytes.size: bytes -> nat``. Return the size of
  the sequence of bytes. It is translated to ``SIZE`` in Michelson.

  Example::

    let s = Bytes.pack (1,2,3,4) in
    let n = Bytes.length s in
    if n > 10p then failwith "serialization too long";
    ...
    
* ``Bytes.concat: bytes list -> bytes``. Append all the sequences of
  bytes of a list into a single sequence of bytes. It is translated to
  ``CONCAT`` in Michelson.

  Example::

    let s = Bytes.concat [ 0x616161; 0x616161 ] in
    if Bytes.length s <> 6 then failwith "bad concat !";
    ...
  
* ``Bytes.slice`` or ``Bytes.sub" of type ``nat -> nat -> bytes ->
  bytes option``. Extract a sequence of bytes within another sequence
  of bytes. ``None`` means that the position or length was invalid. It
  is translated to ``SLICE`` in Michelson.

  Example::

    let b = 0x616161 in
    let s = Bytes.concat [ b;b ] in
    let b' = Bytes.sub 3p 3p in
    if b <> b' then failwith "Bad concat or sub !";
    ...
  
* ``( @ ) : bytes -> bytes -> bytes``. Append two sequences of bytes into a
  single sequence of bytes. It is translated to ``CONCAT`` in
  Michelson.

  Example::

    let b = 0x616161 in
    let s = b @ b in
    let b' = Bytes.sub 3p 3p in
    if b <> b' then failwith "Bad concat or sub !";
    ...

Operations on strings
~~~~~~~~~~~~~~~~~~~~~

A string is a fixed sequence of characters. They are restricted to the
printable subset of 7-bit ASCII, plus some escaped characters (``\n``,
``\t``, ``\b``, ``\r``, ``\\``, ``\"``).


* ``String.length`` or ``String.size`` of type ``string ->
  nat``. Return the size of the string in characters. It is translated
  to ``SIZE`` in Michelson.

  Example::

    let s = "Hello world" in
    let len = String.length s in
    ...
  
* ``String.slice`` or ``String.sub`` with type ``nat -> nat -> string
  -> string option``. Return a substring of a string at the given
  position with the specified length, or ``None`` if invalid. It is
  translated to ``SLICE`` in Michelson.

  Example::

    let s = "Hello world" in
    let world = String.sub 6p 5p s in
    ...

* ``String.concat: string list -> string``. Append all strings of a
  list into a single string. It is translated to ``CONCAT`` in
  Michelson.

  Example::

    let s = String.concat [ "Hello"; " "; "World" ] in
    ...
  
* ``( @ ) : string -> string -> string``. Append two strings into a single
  string. It is translated to ``CONCAT`` in Michelson.

  Example::

    let s = "Hello " @ "World" in
    ...

Operations on lambdas
~~~~~~~~~~~~~~~~~~~~~

* ``Lambda.pipe`` or ``( |> )`` of type ``'a -> ('a -> 'b) -> 'b`` or ``'a
  -> ('a,'b) closure -> 'b``. Applies a function or closure to its
  argument.

   Example::
     
     let square (x : int) = x * x in
     let x = 23 |> square in
     ...

Operations on lists              
~~~~~~~~~~~~~~~~~~~

Lists are immutable data structures containing values (of any type)
that can only be accessed in a sequential order. Since they are
immutable, all **modification** primitives return a new list, and the
list given in argument is unmodified.

* ``( :: ) : 'a -> 'a list -> 'a list`` Add a new element at the head
  of the list. The previous list becomes the tail of the new list.

  Example::

    let new_list = "Hello" :: old_list in
    ...

* ``List.rev : 'a list -> 'a list`` Return the list in the reverse order.

  Example::

    let list = List.rev [7; 5;10] in
    (* list = [10; 5; 7] *)
    ...
  
* ``List.length`` or ``List.size: 'a list -> nat``. Return the length
  of the list. It is translated to ``SIZE`` in Michelson.

  Example::

    let size = List.length [10;20;30;40] in
    (* size = 4 *)
    ...
  
* ``List.iter: ('a -> unit) -> 'a list -> unit``. Iter the function on
  all the elements of a list. Since no value can be returned, it can
  only be used for side effects, i.e. to fail the transaction.  It is
  translated to ``ITER`` in Michelson.

  Example::

    List.iter (fun x ->
      if x < 10tz then failwith "error, element two small")
      list;
    ...
  
* ``List.fold: ('ele * 'acc -> unit) -> 'ele list -> 'acc ->
  'acc``. Iter on all elements of a list, while modifying an
  accumulator. It is translated to ``FOLD`` in Michelson.

  Example::

    let sum = List.fold (fun x ->
       let (ele, acc) = x in
       ele + acc
       ) [1;2;3;4;5] 0
    in
    ...

* ``List.map: ('src -> 'dst) -> 'src list -> 'dst list``. Return a
  list with the result of applying the function on each element of the
  list. It is translated to ``MAP`` in Michelson.

  Example::

    let list = List.map (fun x ->
      x + 1
      ) list in
    ...
  
* ``List.map_fold: ('src * 'acc -> 'dst * 'acc) -> 'src list -> 'acc
  -> 'dst list * 'acc``.  Return a list with the result of applying the
  function on each element of the list, plus an accumulator. It is
  translated to ``MAP_FOLD`` in Michelson.

  Example::

    let (list, acc) = List.map_fold (fun x ->
       let (ele, acc) = x in
       ( ele+1, ele+acc )
       ) [1;2;3;4;5] 0 in
    ...
  
Operations on sets
~~~~~~~~~~~~~~~~~~

Sets are immutable data structures containing uniq values (a
comparable type). Since they are immutable, all **modification**
primitives return a new updated set, and the set given in argument is
unmodified.

* ``Set.update: 'a -> bool -> 'a set -> 'a set``. Update a set for a
  particular element. If the boolean is ``true``, the element is
  added. If the boolean is ``false``, the element is removed. It is
  translated to ``UPDATE`` in Michelson.

  Example::

    let my_set = Set.update 3 true my_set in (* add 3 *)
    let my_set = Set.update 10 false my_set in (* remove 10 *)
    ...
  
* ``Set.add: 'a -> 'a set -> 'a set`` . Add an element to a set, if
  not present. It is translated to ``ADD`` in Michelson.

  Example::

    let my_set = Set.add 3 my_set in
    ...
  
* ``Set.remove: 'a -> 'a set -> 'a set``. Remove an element to a
  set, if present. It is translated to ``REMOVE`` in Michelson.

  Example::

    let my_set = Set.remove 10 my_set in
    ...
  
* ``Set.mem: 'a -> 'a set -> bool``. Return ``true`` if the element is
  in the set, ``false`` otherwise. It is translated to ``MEM`` in
  Michelson.

  Example::

    if not ( Set.mem 3 my_set ) then
      failwith "Missing integer 3 in int set";
    ...
  
* ``Set.cardinal`` or ``Set.size`` with type ``'a set -> nat``. Return
  the number of elements in the set. It is translated to ``SIZE`` in
  Michelson.

  Example::

    let cardinal = Set.size my_set in
    if cardinal < 10p then failwith "too few elements";
    ...
  
* ``Set.iter: ('ele -> unit) -> 'ele set -> unit``. Apply a function
  on all elements of the set. Since no value can be returned, it can
  only be used for side effects, i.e. to fail the transaction.  It is
  translated to ``ITER`` in Michelson.
  
  Example::

    Set.iter (fun ele ->
      if ele < 0 then failwith "negative integer") my_set;
    ...
  
* ``Set.fold: ('ele * 'acc -> unit) -> 'ele set -> 'acc ->
  'acc``. Apply a function on all elements of the set, updating an
  accumulator and returning it at the end. It is translated to
  ``FOLD`` in Michelson.

  Example::

    (* compute the sum of elements *)
    let sum = Set.fold (fun x ->
      let (ele, acc) = x in
      ele + acc
      ) my_set
    in
    ...
  
* ``Set.map: ('src -> 'dst) -> 'src set -> 'dst set``. Return a set
  where all elements are the result of applying the function on the
  elements of the former set. It is translated to ``MAP`` in
  Michelson.

  Example::
    
    let set_plus_one = Set.map (fun x -> x + 1) my_set in
    ...
  
* ``Set.map_fold: ('src * 'acc -> 'dst * 'acc) -> 'src set -> 'acc ->
  'dst set * 'acc``.  Apply a function on all the elements of a set,
  return a new set with the results of the function, and an
  accumulator updated at each step. It is translated to ``MAP_FOLD``
  in Michelson.

  Example::

    let (negated_set, min_elt) = Set.map_fold (fun (ele, acc) ->
       let acc = match acc with
         | None -> Some ele
         | Some acc -> Some (if acc > ele then ele else acc)
       in
       let negated_ele = -ele in
       (negated_ele, acc)
       ) my_set None
    in
    ...
    
Operations on maps
~~~~~~~~~~~~~~~~~~

Maps are immutable data structures containing associations between
keys (a comparable type) and values (any type). Since they are
immutable, all **modification** primitives return a new updated map,
and the map given in argument is unmodified.
  
* ``Map.add: 'key -> 'val -> ('key,'val) map -> ('key,'val)
  map``. Return a map with a new association between a key and a
  value. If an association previously existed for the same key, it is
  not present in the new map. It is translated to ``ADD`` in
  Michelson.

  Example::

    let map = ( Map : (int, string) map ) in
    let map = Map.add 1 "Hello" map in
    let map = Map.add 2 "World" map in
    ...

* ``Map.remove: 'key -> ('key,'val) map -> ('key,'val) map``. Return a
  map where any associated with the key has been removed. It is
  translated to ``REMOVE`` in Michelson.

  Example::

    let new_map = Map.remove param old_map in
    ...

* ``Map.find: 'key -> ('key,'val) map -> 'val option``. Return the
  value associated with a key in the map. It is translated to ``GET``
  in Michelson.

  Example::

    let v = match Map.find param my_map with
      | None -> failwith ("param is not in the map", param)
      | Some v -> v
    in
    ...

* ``Map.update: 'key -> 'val option -> ('key,'val) map -> ('key,'val)
  map``. Return a new map where the association between the key and
  the value has been removed (case ``None``) or added/updated (case
  ``Some v``). It is translated to ``UPDATE`` in Michelson.

  Example::

    let new_map = Map.update key None old_map in (* removed *)
    let new_map = Map.update key (Some v) new_map in (* added *)
    ...
  
* ``Map.mem: 'key -> ('key, 'val) map -> bool``. Return ``true`` if an
  association exists in the map for the key, ``false`` otherwise. It
  is translated to ``MEM`` in Michelson.

  Example::

    let sender = Current.sender () in
    if not ( Map.mem sender owners_map ) then
      failwith ("not allowed", sender);
    ...

* ``Map.cardinal`` or ``Map.size`` with type ``('key,'val) map ->
  nat``. Return the number of associations (i.e. uniq keys) in the
  map. It is translated to ``SIZE`` in Michelson.

  Example::

    if Map.size owners = 0 then
      failwith "you cannot remove all owners";
    ...
  
* ``Map.iter: ('key * 'val -> unit) -> ('key,'val) map ->
  unit``. Apply a function on all associations in the map. Since no
  value can be returned, it can only be used for side effects, i.e. to
  fail the transaction. It is translated to ``ITER`` in Michelson.

  Example::

    Map.iter (fun x ->
      let (key, val) = x in
      if val < 0 then
        failwith "No option should be negative"
      ) map;
    ...

* ``Map.fold: (('key * 'val) * 'acc -> unit) -> ('key,'val) map ->
  'acc -> 'acc``. Apply a function on all associations of the map,
  updating and returning an accumulator. It is translated to ``FOLD``
  in Michelson.

  Example::

    let sum_vals = Map.fold (fun x ->
      let ( (key, val), acc ) = x in
      acc + key
      ) map 0p
    in
    ...

* ``Map.map: ('key * 'src -> 'dst) -> ('key,'src) map -> ('key,'dst)
  map``. Apply a function on all associations of a map, and return a
  new map where keys are now associated with the return values of the
  function. It is translated to ``MAP`` in Michelson.

  Example::

    let negated_values = Map.map (fun x ->
      let (key, val) = x in
      - val
      ) map
    in
    ...

* ``Map.map_fold: (('key * 'src) * 'acc -> 'dst * 'acc) -> ('key,'src)
  map -> 'acc -> ('key,'dst) map * 'acc``.  Apply a function on all
  associations of a map, returning both a new map and an updated
  accumulator. It is translated to ``MAP_FOLD`` in Michelson.

  Example::

    let negated_values, min_key = Map.map_fold (fun x ->
      let ( (key, val) , acc ) = x in
      let acc = match acc with
        | None -> Some key
        | Some v -> if v < key then Some key else acc
      in
      ( - key, acc )
      ) map None
    in
    ...

  
Operations on Big maps
~~~~~~~~~~~~~~~~~~~~~~

Big maps are a specific kind of maps, optimized for storing. They can
be updated incrementally and scale to a high number of associations,
whereas standard maps will have an expensive serialization and
deserialization cost. You are limited by Michelson to one big map per
smart contract, that should appear as the first element of the storage.

* ``Map.find: 'key -> ('key,'val) big_map -> 'val option``. Return the
  value associated with a key in the map. It is translated to ``GET``
  in Michelson.

  Example::

    let v = match Map.find param my_map with
      | None -> failwith ("param is not in the map", param)
      | Some v -> v
    in
    ...

* ``Map.update: 'key -> 'val option -> ('key,'val) big_map -> ('key,'val)
  big_map``. Return a new map where the association between the key and
  the value has been removed (case ``None``) or added/updated (case
  ``Some v``). It is translated to ``UPDATE`` in Michelson.

  Example::

    let new_map = Map.update key None old_map in (* removed *)
    let new_map = Map.update key (Some v) new_map in (* added *)
    ...
  
* ``Map.mem: 'key -> ('key, 'val) big_map -> bool``. Return ``true`` if an
  association exists in the map for the key, ``false`` otherwise. It
  is translated to ``MEM`` in Michelson.

  Example::

    let sender = Current.sender () in
    if not ( Map.mem sender owners_map ) then
      failwith ("not allowed", sender);
    ...

Operations on generic collections
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These primitives should not be used directly in Liquidity. They are
only used by the decompiler. They are automatically replaced during
typing by the corresponding primitive for the collection of the
argument (in either ``List``, ``Set``, ``Map``, ``String`` or
``Bytes``). However, they can be used to write some polymorphic code on
collections.

* ``Coll.update`` 
* ``Coll.mem``    
* ``Coll.find``   
* ``Coll.size``   
* ``Coll.concat`` 
* ``Coll.slice``  
* ``Coll.iter``   
* ``Coll.fold``   
* ``Coll.map``    
* ``Coll.map_fold``


From Michelson to Liquidity
---------------------------

Here is a table of how Michelson instructions translate to Liquidity:

  
* ``ADDRESS``: ``Contract.address addr``
* ``AMOUNT``: ``Current.amount()``
* ``ABS``: ``abs x``
* ``ADD``: ``x + y``
* ``AND``: ``x land y`` or ``x && y``
* ``BALANCE``: ``Current.balance()``
* ``BLAKE2B``: ``Crypto.blake2b bytes``
* ``CAR``: ``x.(0)``
* ``CDR``: ``x.(1)``
* ``CAST``: not available
* ``CHECK_SIGNATURE``: ``Crypto.check key sig bytes``
* ``COMPARE``: ``compare x y``
* ``CONCAT``: ``String.concat list`` or ``bytes.concat list``
* ``CONS``: ``x :: y``
* ``CONTRACT``
* ``CREATE_ACCOUNT``: ``Account.create``
* ``CREATE_CONTRACT``
* ``DIP``: automatic stack management
* ``DROP``: automatic stack management
* ``DUP``: automatic stack management
* ``EDIV``: ``x / y``
* ``EMPTY_MAP``: ``(Map : (int, string) map)``
* ``EMPTY_SET``: ``(Set : int set)``
* ``EQ``: ``x = y``
* ``EXEC``: ``x |> f``
* ``FAILWITH``: ``Current.failwith ("error",x)``
* ``GE``: ``x >= y``
* ``GET``: ``Map.find key map``
* ``GT``: ``x > y``
* ``HASH_KEY``: ``Crypto.hash_key k``
* ``IF``: ``if COND_EXPR then EXPR_IF_TRUE else EXPR_IF_FALSE``
* ``IF_CONS``: ``match list with [] -> EXPR | head :: tail -> EXPR``
* ``IF_LEFT``: ``match variant with Left x -> EXPR | Right x -> EXPR``
* ``IF_NONE``: ``match option with None -> EXPR | Some x -> EXPR``
* ``IMPLICIT_ACCOUNT``: ``Account.default keyhash``
* ``INT``: ``int x``
* ``ISNAT``:``is_nat x`` or ``match%int x with Plus x -> ... | Minus y -> ...``
* ``ITER``: ``Loop.loop (fun x -> ...; (cond, x')) x0``
* ``LAMBDA``: ``fun x -> ...``
* ``LE``: ``x <= y``
* ``LEFT``: ``Left x``
* ``LOOP``: ``Loop.loop (fun x -> ...; (cond, x')) x0``
* ``LOOP_LEFT``:
* ``LSL``: ``x lsl y`` or ``x << y``
* ``LSR`` ``x lsr y`` or ``x >> y``
* ``LT``: ``x < y``
* ``MAP``: ``List.map``, ``Set.map``, ``Map.map``
* ``MEM``: ``Set.mem ele set``, ``Map.mem key map``
* ``MUL``: ``x * y``
* ``NEG``: ``~- x``
* ``NEQ``: ``x <> y``
* ``NIL``: ``( [] : int list)``
* ``NONE``: ``(None : int option)``
* ``NOT``: ``not x``
* ``NOW``: ``Current.time ()``
* ``OR``: ``x lor y`` or ``x || y``
* ``PACK``: ``Bytes.pack x``
* ``PAIR``: ``( x, y )``
* ``PUSH``: automatic stack management
* ``RENAME``: automatic annotations management
* ``RIGHT``: ``Right x``
* ``SENDER``: ``Current.sender()``
* ``SIZE``: ``List.size list``, ``String.size``, ``Bytes.size``, ``Set.size``
* ``SELF``: ``Contract.self ()``
* ``SET_DELEGATE``: ``Contract.set_delegate (Some keyhash)``
* ``SHA256``: ``Crypto.sha256 bytes``
* ``SHA512``: ``Crypto.sha512 bytes``
* ``SLICE``: ``String.sub pos len string`` or ``Bytes.sub``
* ``SOME``: ``Some x``
* ``SOURCE``: ``Current.source()``
* ``STEPS_TO_QUOTA``: ``Current.gas()``
* ``SUB``: ``x - y``
* ``SWAP``: automatic stack management
* ``TRANSFER_TOKENS``: ``Contract.call contract amount param``
* ``UNIT``: ``()``
* ``UNPACK``: ``(unpack bytes : int list option)``
* ``UPDATE``: ``Set.update key true set`` or ``Map.update key (Some val) map``
* ``XOR``: ``x lxor y``

Liquidity Grammar
-----------------

Toplevel:

* ``[%%version`` FLOAT ``]``
* ``let%init storage =`` Expression
* ``let%entry main (parameter:`` Type ``) (storage:`` Type ``) =`` Expression
* ``type`` LIDENT ``=`` Type
* ``type`` LIDENT ``= {`` [ LIDENT ``:`` Type ``;``]+ ``}``
* ``type`` LIDENT ``= [ ``|`` UIDENT ``of`` Type ]+

Expression:

* LIDENT
* UIDENT ``.`` LIDENT
* Expression ``.`` LIDENT
* Expression ``.`` LIDENT ``<-`` Expression
* ``if`` Expression ``then`` Expression
* ``if`` Expression ``then`` Expression ``else`` Expression
* ``Contract.create`` Expression Expression Expression Expression
  Expression Expression ``(fun ( parameter:`` Type ``) (storage:``
  Type ``) ->`` Expression ``)``
* ``(Contract.at`` Expression ``:`` Type ``)``
* ``(Bytes.unpack`` Expression ``:`` Type ``option )``
* ``let`` LIDENT ``=`` Expression ``in`` Expression
* ``let%inline`` LIDENT ``=`` Expression ``in`` Expression
* Expression ``;`` Expression
* ``Loop.loop (fun`` LIDENT ``->`` Expression ``)`` Expression
* Expression Expression
* ``match%nat`` Expression ``with | Plus`` LIDENT ``->`` Expression ``| Minus`` LIDENT ``->`` Expression
* ``match`` Expression ``with | Left`` LIDENT ``->`` Expression ``| Right`` LIDENT ``->`` Expression
* ``match`` Expression ``with | [] ->`` Expression ``|`` LIDENT ``::`` LIDENT ``->`` Expression
* ``match`` Expression ``with`` [ ``|`` Pattern ``->`` Expression ]*
* ``Left`` Expression
* ``Right`` Expression
* ``Some`` Expression
* Expression ``::`` Expression
* Constant

Pattern:

* UIDENT
* UIDENT LIDENT
* ``_``
* ``(`` LIDENT [``,`` LIDENT]* ``)``

Type:

* ``unit``
* ``bool``
* ``int``
* ``nat``
* ``tez``
* ``string``
* ``bytes``
* ``timestamp``
* ``key``
* ``key_hash``
* ``signature``
* ``operation``
* ``address``
* Type ``option``
* Type ``list``
* Type ``contract``
* Type ``set``
* ``(`` Type ``,`` Type ``) variant``
* ``(`` Type ``,`` Type ``) map``
* ``(`` Type ``,`` Type ``) big_map``
* ``(`` Type ``,`` Type ``) variant``
* ``(`` Type ``,`` Type ``) variant``
* Type [ ``*`` Type]+
* Type ``->`` Type
* ``_``
* LIDENT
  
Constant:

* ``tz1...``
* ...  
