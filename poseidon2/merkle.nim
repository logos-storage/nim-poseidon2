#
# Merkle trees, used a drop-in replacement for hash functions
#

import constantine/math/arithmetic
import constantine/math/io/io_fields
import ./types
import ./io
import ./compress

const KeyNone              = F.fromHex("0x0")
const KeyBottomLayer       = F.fromHex("0x1")
const KeyOdd               = F.fromHex("0x2")
const KeyOddAndBottomLayer = F.fromhex("0x3")

type Merkle*[flavour: static Flavour] = object
  todo: seq[F]               # nodes that haven't been combined yet
  width: int                 # width of the current subtree
  leafs: int                 # amount of leafs processed

func init[which](merkle: var Merkle[which]) = 
  merkle.width = 2

func init*(_: type Merkle, which: static Flavour = HorizenLabsOld): Merkle[which] =
  result.init

func compress[which](merkle: var Merkle[which], odd: static bool) =
  when odd:
    let a = merkle.todo.pop()
    let b = zero
    let key = if merkle.width == 2: KeyOddAndBottomLayer else: KeyOdd
    merkle.todo.add(compression(a, b, key = key, which = which))
    merkle.leafs += merkle.width div 2 # zero node represents this many leafs
  else:
    let b = merkle.todo.pop()
    let a = merkle.todo.pop()
    let key = if merkle.width == 2: KeyBottomLayer else: KeyNone
    merkle.todo.add(compression(a, b, key = key, which = which))
  merkle.width *= 2

func update*[which](merkle: var Merkle[which], element: F) =
  merkle.todo.add(element)
  inc merkle.leafs
  merkle.width = 2
  while merkle.width <= merkle.leafs and merkle.leafs mod merkle.width == 0:
    merkle.compress(odd = false)

func finish*[which](merkle: var Merkle[which]): F =
  assert merkle.todo.len > 0, "merkle root of empty sequence is not defined"

  if merkle.leafs == 1:
    merkle.compress(odd = true)

  while merkle.todo.len > 1:
    if merkle.leafs mod merkle.width == 0:
      merkle.compress(odd = false)
    else:
      merkle.compress(odd = true)

  return merkle.todo[0]

# Merkle root of a sequence of field elements (here the Merkle tree is used as a hash function!)
func digest*(_: type Merkle, elements: openArray[F], which: static Flavour = HorizenLabsOld): F =
  var merkle = Merkle.init(which = which)
  for element in elements:
    merkle.update(element)
  return merkle.finish()

# Merkle root of a sequence of bytes (here the Merkle tree is used as a hash function!)
func digest*(_: type Merkle, bytes: openArray[byte], which: static Flavour = HorizenLabsOld): F =
  var merkle = Merkle.init(which = which)
  for element in bytes.elements(F):
    merkle.update(element)
  return merkle.finish()
