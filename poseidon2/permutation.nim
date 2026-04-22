import ./types
import ./roundfun

#-------------------------------------------------------------------------------

# the Poseidon2 permutation, "old" round constants (mutable, in-place version)
proc permInPlaceOld(x, y, z : var F) =
  linearLayer(x, y, z)
  for j in 0..3:
    externalRoundOld(j, x, y, z)
  for j in 0..55:
    internalRoundOld(j, x, y, z)
  for j in 4..7:
    externalRoundOld(j, x, y, z)

# the Poseidon2 permutation, "old" ronud constants
func permOld(xyz: S) : S =
  var (x,y,z) = xyz
  permInPlaceOld(x, y, z)
  return (x,y,z)

#-------------------------------------------------------------------------------

# the Poseidon2 permutation, "new" round constants (mutable, in-place version)
proc permInPlaceNew(x, y, z : var F) =
  linearLayer(x, y, z)
  for j in 0..3:
    externalRoundNew(j, x, y, z)
  for j in 0..55:
    internalRoundNew(j, x, y, z)
  for j in 4..7:
    externalRoundNew(j, x, y, z)

# the Poseidon2 permutation, "new" ronud constants
func permNew(xyz: S) : S =
  var (x,y,z) = xyz
  permInPlaceNew(x, y, z)
  return (x,y,z)

#-------------------------------------------------------------------------------
# selectable round constants

# the Poseidon2 permutation (mutable, in-place version)
proc permInPlace*(x, y, z: var F, which: static Flavour = HorizenLabsOld) =
  case which
    of HorizenLabsOld: permInPlaceOld(x,y,z)
    of HorizenLabsNew: permInPlaceNew(x,y,z)

# the Poseidon2 permutation, "old" ronud constants
func perm*(xyz: S, which: static Flavour = HorizenLabsOld) : S =
  var (x,y,z) = xyz
  case which
    of HorizenLabsOld: permInPlaceOld(x,y,z)
    of HorizenLabsNew: permInPlaceNew(x,y,z)
  return (x,y,z)

#-------------------------------------------------------------------------------
