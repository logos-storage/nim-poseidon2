import std/unittest
import constantine/math/arithmetic
import poseidon2/io
import poseidon2/permutation
import poseidon2/compress

suite "compress":

  test "uses permutation to compress two elements":
    check bool(compression(1.toF, 2.toF) == (1.toF, 2.toF, 0.toF).perm[0])
    check bool(compression(3.toF, 4.toF) == (3.toF, 4.toF, 0.toF).perm[0])

  test "allows for keyed compression":
    check bool(compression(1.toF, 2.toF, key=3.toF) == (1.toF, 2.toF, 3.toF).perm[0])
    check bool(compression(4.toF, 5.toF, key=6.toF) == (4.toF, 5.toF, 6.toF).perm[0])
