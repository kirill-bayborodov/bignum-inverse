# Variant B ASM benchmark report

## Method

The C11 and YASM objects were compiled from the same current source revision with `-O3 -march=x86-64`. The same benchmark harness, operands, iteration counts and `CLOCK_MONOTONIC` timing were used for both backends. Workloads covered odd modulus `2^(64n)-1` with `a=7`, power-of-two modulus `2^(64n-8)` with `a=3`, and general even CRT modulus `3*2^(64n-8)` with `a=5`.

## Results

| Workload | Words | C11 ns/call | ASM ns/call | ASM relative |
|---|---:|---:|---:|---:|
| odd | 1 | 6,804.109 | 8,666.777 | 1.274x |
| odd | 2 | 11,012.757 | 14,536.346 | 1.320x |
| odd | 4 | 20,302.140 | 25,467.811 | 1.254x |
| odd | 8 | 39,179.190 | 49,801.349 | 1.271x |
| odd | 16 | 86,456.480 | 111,178.277 | 1.286x |
| odd | 32 | 216,949.933 | 263,906.217 | 1.216x |
| power of two | 1 | 3,397.033 | 4,428.412 | 1.304x |
| power of two | 2 | 3,760.629 | 4,347.653 | 1.156x |
| power of two | 4 | 4,232.749 | 4,278.181 | 1.011x |
| power of two | 8 | 3,821.320 | 4,743.064 | 1.241x |
| power of two | 16 | 3,917.597 | 5,075.110 | 1.295x |
| power of two | 32 | 4,215.987 | 5,508.333 | 1.307x |
| general even CRT | 1 | 7,332.374 | 9,732.196 | 1.327x |
| general even CRT | 2 | 9,012.534 | 10,739.491 | 1.192x |
| general even CRT | 4 | 9,878.273 | 12,735.639 | 1.289x |
| general even CRT | 8 | 14,117.420 | 17,667.262 | 1.252x |
| general even CRT | 16 | 22,966.160 | 27,293.230 | 1.188x |
| general even CRT | 32 | 44,218.700 | 55,754.810 | 1.261x |

Every sample completed successfully and the C11/ASM checksums matched for all 18 workload points. The generated standalone ASM is therefore functionally equivalent on this matrix, but it is currently slower than optimized C11 in every measured point. This candidate must not be represented as a performance improvement.

## Interpretation

The current ASM is a compiler-generated translation of the C11 variant B. It preserves the ABI and semantics but does not yet provide a hand-tuned register-level implementation. The slowdown is consistent with large stack frames, repeated record copies, SIMD-assisted compiler scheduling differences and call/temporary overhead in the generic CRT path.

The ASM candidate is suitable as a correctness baseline, not as the final optimized implementation. The next optimization should specialize the one-word CRT and power-of-two paths in registers, then benchmark again before considering a commit. Multiword CRT should remain on the generated fallback until the specialized path passes the same matrix.
