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

#
# domain separation convention: 
#
# The sponge state is initialized to `(0,0,domsep)` with
#
# domsep IV := (2^64 + 2^24*padding + 2^16*inputfmt + 2^8*t + rate)
#
# - t    = 3 (the state width)
# - rate = 1 or 2
# - input format is:
#     - 254 when hashing BN254 field elements
#     - 8   when hashing bytes
#     - 1   when hashing bits (not implemented)
# - padding is
#     - 1   the `10*` padding convention for field elements
#     - 16  the `10*` padding convention for bytes only (to a multiple of 31 or 62, depending on rate)
#     - 17  padding both bytes (to a multiple of 31) and then the resulting field elements (multiple of rate)
#     - 255 for no padding
#
# note: domain separation is IMPORTANT, especially when mixing byte sequences
# with field element sequences, and not being very careful with padding!
#

const DOMSEP_IV_RATE1_FELTS*: F = F.fromHex("0x10000000001fe0301")
const DOMSEP_IV_RATE1_BYTES*: F = F.fromHex("0x10000000011080301")

const DOMSEP_IV_RATE2_FELTS*: F = F.fromHex("0x10000000001fe0302")
const DOMSEP_IV_RATE2_BYTES*: F = F.fromHex("0x10000000011080302")

func init[which](sponge: var Sponge[1,which], domSep: F = DOMSEP_IV_RATE1_FELTS) =
  sponge.s0 = zero
  sponge.s1 = zero
  sponge.s2 = domSep

func update*[which](sponge: var Sponge[1,which], element: F) = 
  sponge.s0 += element
  permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)

func finish*[which](sponge: var Sponge[1,which]): F = 
  # padding
  sponge.s0 += one
  permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)
  return sponge.s0

#-------------------------------------------------------------------------------
# rate = 2

func init[which](sponge: var Sponge[2,which], domSep: F = DOMSEP_IV_RATE2_FELTS) =
  sponge.s0 = zero
  sponge.s1 = zero
  sponge.s2 = domSep
  sponge.even = true

func update*[which](sponge: var Sponge[2,which], element: F) = 
  if sponge.even:
    sponge.s0 += element
  else:
    sponge.s1 += element
    permInPlace(sponge.s0, sponge.s1, sponge.s2, which = which)
  sponge.even = not sponge.even

func finish*[which](sponge: var Sponge[2,which]): F = 
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

func initWithDomSep*(_: type Sponge, rate: static int = 2, domSep: F, which: static Flavour = HorizenLabsOld): Sponge[rate,which] =
  when rate notin {1, 2}:
    {.error: "only rate 1 and 2 are supported".}
  result.init(domSep = domSep)
  # spone.s2 = domSep

# digest of a sequence of field elements
func digest*(_: type Sponge, elements: openArray[F], rate: static int = 2, which: static Flavour = HorizenLabsOld): F =

  var domsep: F 
  if rate == 1:
    domsep = DOMSEP_IV_RATE1_FELTS
  elif rate == 2:
    domsep = DOMSEP_IV_RATE2_FELTS
  else:
    discard

  var sponge = Sponge.initWithDomSep(rate = rate, domSep = domsep, which = which)
  for element in elements:
    sponge.update(element)
  return sponge.finish()

# digest of a sequence of bytes
func digest*(_: type Sponge, bytes: openArray[byte], rate: static int = 2, which: static Flavour = HorizenLabsOld): F =

  var domsep: F 
  if rate == 1:
    domsep = DOMSEP_IV_RATE1_BYTES
  elif rate == 2:
    domsep = DOMSEP_IV_RATE2_BYTES
  else:
    discard

  var sponge = Sponge.initWithDomSep(rate = rate, domSep = domsep, which = which)
  for element in bytes.elements(F):
    sponge.update(element)
  return sponge.finish()

#-------------------------------------------------------------------------------
