import ./types
import ./permutation
import ./io
import constantine/math/io/io_fields
import constantine/math/arithmetic

type
  Sponge*[rate: static int, flavour: static Flavour] = object
    s0: F
    s1: F
    s2: F
    when rate == 2:
      even: bool

#-------------------------------------------------------------------------------
# rate = 1

func init[which](sponge: var Sponge[1,which]) =
  # domain separation IV := (2^64 + 256*t + r)
  const IV = F.fromHex("0x10000000000000301")
  sponge.s0 = zero
  sponge.s1 = zero
  sponge.s2 = IV

func update*[which](sponge: var Sponge[1,which], element: F) = # , which: static Flavour = HorizenLabsOld) =
  sponge.s0 += element
  permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)

func finish*[which](sponge: var Sponge[1,which]): F = # , which: static Flavour = HorizenLabsOld): F =
  # padding
  sponge.s0 += one
  permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)
  return sponge.s0

#-------------------------------------------------------------------------------
# rate = 2

func init[which](sponge: var Sponge[2,which]) =
  # domain separation IV := (2^64 + 256*t + r)
  const IV = F.fromHex("0x10000000000000302")
  sponge.s0 = zero
  sponge.s1 = zero
  sponge.s2 = IV
  sponge.even = true

func update*[which](sponge: var Sponge[2,which], element: F) = # , which: static Flavour = HorizenLabsOld) =
  if sponge.even:
    sponge.s0 += element
  else:
    sponge.s1 += element
    permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)
  sponge.even = not sponge.even

func finish*[which](sponge: var Sponge[2,which]): F = #: static Flavour = HorizenLabsOld): F =
  if sponge.even:
    # padding even input
    sponge.s0 += one
    sponge.s1 += zero
  else:
    # padding odd input
    sponge.s1 += one
  permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)
  return sponge.s0

#-------------------------------------------------------------------------------
# generic

func init*(_: type Sponge, rate: static int = 2, which: static Flavour = HorizenLabsOld): Sponge[rate,which] =
  when rate notin {1, 2}:
    {.error: "only rate 1 and 2 are supported".}
  result.init

func digest*(_: type Sponge, elements: openArray[F], rate: static int = 2, which: static Flavour = HorizenLabsOld): F =
  var sponge = Sponge.init(rate = rate, which = which)
  for element in elements:
    sponge.update(element)
  return sponge.finish()

func digest*(_: type Sponge, bytes: openArray[byte], rate: static int = 2, which: static Flavour = HorizenLabsOld): F =
  var sponge = Sponge.init(rate = rate, which = which)
  for element in bytes.elements(F):
    sponge.update(element)
  return sponge.finish()
