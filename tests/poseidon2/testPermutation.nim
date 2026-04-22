import std/unittest

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints

import poseidon2/types
import poseidon2/io
import poseidon2/permutation

suite "permutation":

  test "permutation in place (default version)":
    var x: F = toF(0)
    var y: F = toF(1)
    var z: F = toF(2)
    permInPlace(x, y, z)
    check toDecimal(x) == "21882471761025344482456282050943515707267606647948403374880378562101343146243"
    check toDecimal(y) == "09030699330013392132529464674294378792132780497765201297316864012141442630280"
    check toDecimal(z) == "09137931384593657624554037900714196568304064431583163402259937475584578975855"

  test "permutation in place (old version)":
    var x: F = toF(0)
    var y: F = toF(1)
    var z: F = toF(2)
    permInPlace(x, y, z, HorizenLabsOld)
    check toDecimal(x) == "21882471761025344482456282050943515707267606647948403374880378562101343146243"
    check toDecimal(y) == "09030699330013392132529464674294378792132780497765201297316864012141442630280"
    check toDecimal(z) == "09137931384593657624554037900714196568304064431583163402259937475584578975855"

  test "permutation in place (new version)":
    var x: F = toF(0)
    var y: F = toF(1)
    var z: F = toF(2)
    permInPlace(x, y, z, HorizenLabsNew)
    check toDecimal(x) == "05297208644449048816064511434384511824916970985131888684874823260532015509555"
    check toDecimal(y) == "21816030159894113985964609355246484851575571273661473159848781012394295965040"
    check toDecimal(z) == "13940986381491601233448981668101586453321811870310341844570924906201623195336"
