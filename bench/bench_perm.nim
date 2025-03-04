
#
# nimble build -d:release
#

import strformat
import times, os, strutils

import constantine/math/arithmetic
import constantine/math/io/io_fields
import constantine/math/io/io_bigints

import poseidon2/types
import poseidon2/io
import poseidon2/permutation

#-------------------------------------------------------------------------------

func seconds*(x: float): string = fmt"{x:.4f} seconds"

func quoted*(s: string): string = fmt"`{s:s}`"

template withMeasureTime*(doPrint: bool, text: string, code: untyped) =
  block:
    if doPrint:
      let t0 = epochTime()
      code
      let elapsed = epochTime() - t0
      let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 4)
      echo ( text & " took " & elapsedStr & " seconds" )
    else:
      code

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

  echo "quick & dirty nim-poseidon2-bn254 benchmark"
  
  let n: int = 1000000

  let text = fmt"{n} Poseidon2 permutations"
  withMeasureTime(true,text): 
    iteratePerm(n)

  let mb = float64(n)*62.0/1024/1024
  echo fmt"that corresponds to about {mb:.2f} megabytes of linear hashing"

