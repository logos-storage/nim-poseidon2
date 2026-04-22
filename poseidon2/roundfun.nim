import
  constantine/math/arithmetic,
  constantine/named/algebras

import ./types
import ./roundconst_old
import ./roundconst_new

#-------------------------------------------------------------------------------

const externalRoundConstOld : array[24, F] = arrayFromHex( externalRoundConstOldStr )
const internalRoundConstOld : array[56, F] = arrayFromHex( internalRoundConstOldStr )

const externalRoundConstNew : array[24, F] = arrayFromHex( externalRoundConstNewStr )
const internalRoundConstNew : array[56, F] = arrayFromHex( internalRoundConstNewStr )

#-------------------------------------------------------------------------------

# inplace sbox, x => x^5
func sbox*(x: var F) : void =
  var y = x
  square(y)
  square(y)
  x *= y

func linearLayer*(x, y, z : var F) =
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

#-------------------------------------------------------------------------------

func internalRoundOld*(j: int; x, y, z: var F) =
  x += internalRoundConstOld[j]
  sbox(x)
  var s = x ; s += y ;  s += z
  double(z)
  x += s
  y += s
  z += s

func externalRoundOld*(j: int; x, y, z : var F) =
  x += externalRoundConstOld[3*j+0]
  y += externalRoundConstOld[3*j+1]
  z += externalRoundConstOld[3*j+2]
  sbox(x) ; sbox(y) ; sbox(z)
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

#-------------------------------------------------------------------------------

func internalRoundNew*(j: int; x, y, z: var F) =
  x += internalRoundConstNew[j]
  sbox(x)
  var s = x ; s += y ;  s += z
  double(z)
  x += s
  y += s
  z += s

func externalRoundNew*(j: int; x, y, z : var F) =
  x += externalRoundConstNew[3*j+0]
  y += externalRoundConstNew[3*j+1]
  z += externalRoundConstNew[3*j+2]
  sbox(x) ; sbox(y) ; sbox(z)
  var s = x ; s += y ; s += z
  x += s
  y += s
  z += s

#-------------------------------------------------------------------------------
