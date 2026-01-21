version     = "0.1.0"
author      = "nim-poseidon2 authors"
description = "Poseidon2 hash function"
license     = "MIT"

installExt  = @["nim"]

#requires "https://github.com/mratsim/constantine#bc3845aa492b52f7fef047503b1592e830d1a774"
requires "https://github.com/mratsim/constantine#782d838e7a073262750eff593af6dfff3ff832dd"

bin = @["bench/bench_perm", "bench/bench_griffin"]