# bignum_inverse benchmark comparison

The measurements below use the same release configuration, seed, input profile, operation profile, warmup and iteration count for both backends. The benchmark framework reports the measured kernel interval; the wall-clock values are supplementary sandbox measurements.

| Backend | Profile | Iterations | Framework ns/call | Wall-clock sample |
|---|---|---:|---:|---:|
| C11 reference | one-word, nonzero, binary-euclid, kernel-only, seed 123456789 | 5,000 | 17,602.488 | 0.0930 s |
| YASM x86-64 | one-word, nonzero, binary-euclid, kernel-only, seed 123456789 | 5,000 | 19,321.462 | 0.1018 s |

Three additional 3,000-iteration ASM samples ranged from 19,127.833 to 20,112.208 ns/call. Three C11 samples ranged from 17,731.633 to 17,834.954 ns/call. Therefore this implementation snapshot proves functional parity but does **not** yet prove the required ASM speed advantage; the current generated YASM is approximately 9.8% slower in this workload. The result is retained as a baseline rather than presented as an optimization success.

The benchmark protocol completed successfully for both backends, with `successful=5000`, identical fingerprint and checksum, and the `Benchmark finished.` marker. Hardware `perf` comparison remains environment-dependent; the official Makefile and CI were not changed.
