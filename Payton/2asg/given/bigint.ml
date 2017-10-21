(* $Id: bigint.ml,v 1.5 2014-11-11 15:06:24-08 - - $ *)

open Printf

let complain message =
    ( flush stdout;
      Printf.eprintf "%s: %s\n" Sys.argv.(0) message;
      flush stderr )

module Bigint = struct

    type sign     = Pos | Neg
    type bigint   = Bigint of sign * int list
    let  radix    = 10
    let  radixlen =  1

    let car       = List.hd
    let cdr       = List.tl
    let map       = List.map
    let reverse   = List.rev
    let strcat    = String.concat
    let strlen    = String.length
    let strsub    = String.sub
    let zero      = Bigint (Pos, [])

    let rec cmp' value1 value2 =
        if List.length value1 = 0 && List.length value2 = 0 then 0
        else if List.length value1 = 0 && List.length value2 <> 0 then -1
        else if List.length value1 <> 0 && List.length value2 = 0 then 1
        else if List.hd value1 > List.hd value2 then 1
        else if List.hd value1 < List.hd value2 then -1
        else cmp' (List.tl value1) (List.tl value2)


    let cmp value1 value2 = 
        if (List.length value1) < (List.length value2) then -1
        else if (List.length value2) > (List.length value1) then 1
        else cmp' (List.rev value1) (List.rev value2)

    let bi_cmp (Bigint (neg1, value1)) (Bigint (neg2, value2)) = 
        if neg1 = Pos && neg2 = Neg then 1
        else if neg1 = Neg && neg2 = Pos then -1
        else if neg1 = Pos && neg2 = Pos then (cmp value1 value2)
        else if neg1 = Neg && neg2 = Neg then (cmp value1 value2)
        else 0

    let charlist_of_string str = 
        let last = strlen str - 1
        in  let rec charlist pos result =
            if pos < 0
            then result
            else charlist (pos - 1) (str.[pos] :: result)
        in  charlist last []

    let bigint_of_string str =
        let len = strlen str
        in  let to_intlist first =
                let substr = strsub str first (len - first) in
                let digit char = int_of_char char - int_of_char '0' in
                map digit (reverse (charlist_of_string substr))
            in  if   len = 0
                then zero
                else if   str.[0] = '_'
                     then Bigint (Neg, to_intlist 1)
                     else Bigint (Pos, to_intlist 0)

    let string_of_bigint (Bigint (sign, value)) =
        match value with
        | []    -> "0"
        | value -> let reversed = reverse value
                   in  strcat ""
                       ((if sign = Pos then "" else "-") ::
                        (map string_of_int reversed))

    let rec add' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, 0       -> list2
        | list1, [], carry   -> add' list1 [carry] 0
        | [], list2, carry   -> add' [carry] list2 0
        | car1::cdr1, car2::cdr2, carry ->
          let sum = car1 + car2 + carry in
          sum mod radix :: add' cdr1 cdr2 (sum / radix)

    let add (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        (* printf "%d\n" (cmp value1 value2); *)
        if neg1 = neg2
        then Bigint (neg1, add' value1 value2 0)
        else zero (* We should be subtracting here. *)


    (* let sub' list1 list2 carry = math (list1, list2, carry) with *)




    let sub (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        if neg1 <> neg2
        then (
                (* For subtracting w/ diff. signs, the sign
                 * is that of the biggest abs(num) *)
                if (cmp value1 value2) = 1
                then Bigint (neg1, add' value1 value2 0)
                else Bigint (neg1, add' value1 value2 0)
             )
        (* else ( 
                
             ) *)
         else zero (* TODO: Actually do the subtraction *)
                   (* This is just a placeholder *)




    (* let sub = add *)
    let mul = add

    let div = add

    let rem = add

    let pow = add

end
