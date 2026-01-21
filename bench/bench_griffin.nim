
#
# nimble build -d:release
#

import strformat
# import strutils

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints

import griffin
import griffin/permutation
import ./shared

#-------------------------------------------------------------------------------

proc iteratePerm(n: int) = 

  var x: F = toF(0)
  var y: F = toF(1)
  var z: F = toF(2)

  for i in 0..<n:
    permInPlace(x, y, z)

  echo "x = ", toDecimal(x)
  echo "y = ", toDecimal(y)
  echo "z = ", toDecimal(z)

#-------------------------------------------------------------------------------

when isMainModule:

  testGriffin()
  echo "----------------------------------"

  echo "quick & dirty Griffin benchmark"
  
  let n: int = 100000

  let text = fmt"{n} Grffin permutations"
  withMeasureTime(true,text): 
    iteratePerm(n)

  let mb = float64(n)*62.0/1024/1024
  echo fmt"that corresponds to about {mb:.2f} megabytes of linear hashing"

