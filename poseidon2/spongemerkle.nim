#
# Merkle trees over a sequence of bytestrings
#

import ./types
import ./merkle
import ./sponge

type SpongeMerkle*[flavour: static Flavour] = object
  merkle: Merkle[flavour]

func init[which](spongemerkle: var SpongeMerkle[which]) =
  spongemerkle.merkle = Merkle.init(which = which)

func init*(_: type SpongeMerkle, which: static Flavour = HorizenLabsOld): SpongeMerkle[which] =
  result.init

func update*[which](spongemerkle: var SpongeMerkle[which], chunk: openArray[byte]) =
  let digest = Sponge.digest(chunk, rate = 2, which = which)
  spongemerkle.merkle.update(digest)

func finish*[which](spongemerkle: var SpongeMerkle[which]): F =
  return spongemerkle.merkle.finish()

func digestFixedChunks*(_: type SpongeMerkle, bytes: openArray[byte], chunkSize: int, which: static Flavour = HorizenLabsOld): F =
  ## Hashes chunks of data with a sponge of rate 2, and combines the
  ## resulting chunk hashes in a merkle root.
  var spongemerkle = SpongeMerkle.init(which = which)
  var index = 0
  while index < bytes.len:
    let start = index
    let finish = min(index + chunkSize, bytes.len)
    spongemerkle.update(bytes.toOpenArray(start, finish - 1))
    index += chunkSize
  return spongemerkle.finish()

func digest*(_: type SpongeMerkle, byteSeqs: openArray[seq[byte]], which: static Flavour = HorizenLabsOld): F =
  ## Hashes chunks of data with a sponge of rate 2, and combines the
  ## resulting chunk hashes in a merkle root.
  var spongemerkle = SpongeMerkle.init(which = which)
  for index in 0..<byteSeqs.len:
    spongemerkle.update(byteSeqs[index])
  return spongemerkle.finish()
