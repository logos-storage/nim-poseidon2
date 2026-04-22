import ./types
import ./permutation

# 2-to-1 compression
func compression*(a, b : F, key = zero, which: static Flavour = HorizenLabsOld) : F =
  var x = a
  var y = b
  var z = key
  permInPlace(x, y, z, which = which)
  return x
