
import
  constantine/math/arithmetic,
  constantine/math/io/io_fields,
  constantine/math/io/io_bigints,
  constantine/named/algebras

#-------------------------------------------------------------------------------

#
# Note: Because of a historical accident, there are unfortunately TWO different sets 
# of "standard" parameters, which is obviously bad for cross-project compatibility.
#
# the switchover happened at 2023/06/23 in the commit
#   <https://github.com/HorizenLabs/poseidon2/commit/bb476b9ca38198cf5092487283c8b8c5d4317c4e>
#
# You can use this type to select between the two. The default is the "old" set.
#
type Flavour* = enum
  HorizenLabsOld          # the "old" round constants
  HorizenLabsNew          # the "new" round constants

type SpongeInput* = enum
  ByteString              # the input of the hash is a sequence of bytes
  FieldElements           # the input of the hash is a sequence of BN254 field elements
  
#-------------------------------------------------------------------------------

type B* = BigInt[254]
type F* = Fr[BN254_Snarks]
type S* = (F,F,F)

#-------------------------------------------------------------------------------

func getZero*() : F =
  var z : F
  setZero(z)
  return z

#-------------------------------------------------------------------------------

const zero* : F = getZero()
const one*  : F = fromHex(F,"0x01")     # note: `fromUint()` does not work at compile time
const two*  : F = fromHex(F,"0x02") 

const twoToThe64* : F = fromHex(F,"0x10000000000000000")

#-------------------------------------------------------------------------------

func hexToF*(s : string, endian: static Endianness = bigEndian) : F =
  let bigint = B.fromHex(s, endian)
  return F.fromBig(bigint)

func arrayFromHex*[N](
    inp: array[N, string],
    endian: static Endianness = bigEndian) : array[N, F] =
  var tmp : array[N, F]
  for i in low(inp)..high(inp):
    tmp[i] = hexToF(inp[i], endian)
  return tmp

#-------------------------------------------------------------------------------

func `+`*(x, y: F): F =  ( var z: F = x ; z += y ; return z )
func `-`*(x, y: F): F =  ( var z: F = x ; z -= y ; return z )
func `*`*(x, y: F): F =  ( var z: F = x ; z *= y ; return z )

func `==`*(a, b: F): bool =
  bool(arithmetic.`==`(a, b))

func sqr*(x : F): F = 
  var y = x
  y.square()
  return y

#-------------------------------------------------------------------------------

func fastPow*(base: F, expo: B): F = 
  var s : F = base
  var a : F = one
  var e : B = expo
  for i in 0..<254:
    if bool(isOdd(e)):
      a *= s
    s.square()
    e.div2()
  return a

#-------------------------------------------------------------------------------

