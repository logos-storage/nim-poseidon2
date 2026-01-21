
import
  constantine/math/arithmetic,
  constantine/math/io/io_fields,
  constantine/math/io/io_bigints

import ../poseidon2/types
import ./roundconst

#-------------------------------------------------------------------------------

const expo_inv : B = fromHex(B,"0x26b6a528b427b35493736af8679aad17535cb9d394945a0dcfe7f7a98ccccccd")

const alpha    : F = fromHex(F,"0x146ecffb34a66316fae66609f78d1310bc14ad7208082ca7943afebb1da4aa4a")
const beta     : F = fromHex(F,"0x2b568115d544c7e941eff6ccc935384619b0fb7d2c5ba6c078c34cf81697ee1c")

const roundConstArray : array[33, F] = arrayFromHex( roundConstStr )

#-------------------------------------------------------------------------------

# inplace sbox, x => x^5
proc pow5(x: var F) : void =
  var y = x
  square(y)
  square(y)
  x *= y

# inplace sbox, x => x^(1/5)
proc powInv5(x: var F) : void =
  x = fastPow(x, expo_inv)

#-------------------------------------------------------------------------------

proc sbox(x, y, z: var F) = 
  x.powInv5()
  y.pow5()
  let u : F = x + y
  var m = beta
  m += sqr(u)
  m += alpha * u     # m = u^2 + alpha*u + beta
  z *= m

proc addRC(round: int, x, y, z: var F) = 
  if (round > 0):
    let j = (round-1) * 3
    x += roundConstArray[ j   ]
    y += roundConstArray[ j+1 ]
    z += roundConstArray[ j+2 ]

proc linear(x, y, z : var F) =
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

proc roundFun(round: int, x, y, z: var F) =
  addRC(round,x,y,z)
  sbox(x,y,z)
  linear(x,y,z)

#-------------------------------------------------------------------------------

# the Griffin permutation (mutable, in-place version)
proc permInPlace*(x, y, z : var F) =
  linear(x, y, z)
  for j in 0..<12:
    roundFun(j, x, y, z)

# the Griffin permutation (pure version)
func perm*(xyz: S) : S =
  var (x,y,z) = xyz
  permInPlace(x, y, z)
  return (x,y,z)

#-------------------------------------------------------------------------------

# known-answer test: the expected permutation of (0,1,2)
const kat: S = 
  ( F.fromHex("0x2311cdb3076c3a7ee37fd5a271e0f3a8a3cc38057d0cea37b78951f43b1b6ff6")
  , F.fromHex("0x1d3aaed9ea361e899e667abd18e5328555b97b5c3890d52b261f940d6ab4df58")
  , F.fromHex("0x22614a0ac719cb623a636adac3bac1b85b5a7a418fcf8ab3a3ae0787fb4bed9d")
  )

proc sanityCheckExpoInv*() =
  let x0 : F = F.fromHex("0x666")
  var x  : F = x0
  x.pow5()
  x.powInv5()
  echo "sanity check /a = " & $(x == x0)
  let y0 : F = F.fromHex("0x777017")
  var y  : F = y0
  y.powInv5()
  y.pow5()
  echo "sanity check /b = " & $(y == y0)

proc testGriffin*() = 
  sanityCheckExpoInv()
  let inp: S = (zero,one,two)
  let candidate = perm(inp)
  let (x,y,z) = candidate
  echo "x = " & $x.toDecimal()
  echo "y = " & $y.toDecimal()
  echo "z = " & $z.toDecimal()
  echo "KAT ok = " & $(candidate == kat)

#-------------------------------------------------------------------------------
