# P1.3 report: multiword hot-path baseline

## Benchmark harness

A separate deterministic harness used `a=7` and `m=2^(64*n)-1` with `n` equal to 2, 4, 8, 16 and 32 words. The modulus is odd and coprime with 7 for these tested sizes. Each point used 100 warm-up calls and 2,000 measured calls for the same C11 and ASM objects.

## Baseline measurements

| Logical modulus length | C11 ns/call | ASM ns/call | C11 successful calls | ASM successful calls |
|---:|---:|---:|---:|---:|
| 2 words | 47,485.973 | 36,699.315 | 2,000 | 2,000 |
| 4 words | 90,877.466 | 70,804.170 | 2,000 | 2,000 |
| 8 words | 182,821.967 | 156,323.655 | 2,000 | 2,000 |
| 16 words | 362,596.415 | 366,654.386 | 2,000 | 2,000 |
| 32 words | 3,733.312 | 4,012.729 | 0 | 0 |

The 32-word timing is not a performance result: both implementations returned failure before completing a valid inverse. It must not be compared with successful rows.

## Blocking correctness finding

The current fixed-capacity signed Bezout implementation cannot represent the coefficient state for at least one valid near-capacity input and returns `BIGNUM_INVERSE_ERROR_NO_INVERSE`. The input has `gcd(7, 2^(2048)-1)=1`, so this is not a legitimate no-inverse case. A hand-tuned multiword ASM kernel must not be added on top of this unverified state.

## Recommendation

Before P1.3 optimization, add a correctness repair or an explicitly documented coefficient-capacity strategy for near-capacity inputs. Options are: reserve extra private coefficient words, use a bounded modular-coefficient representation with a proven even-modulus strategy, or restrict and document the accepted operand range (the last option would be an API contract change and requires explicit approval). Only after a valid near-capacity baseline is established should multiword ASM compare/subtract/halve loops be optimized.
