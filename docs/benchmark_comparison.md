# bignum_inverse benchmark comparison

## Measurement contract

Both backends were built in release mode from the same source revision and run through the same benchmark-framework protocol. The workload was `seed=123456789`, `warmup=100`, `data-count=8`, `iterations=5000`, `input-kind=nonzero`, `operation-kind=binary-euclid`, `measure-mode=kernel-only`, `size-profile=one`, and `capacity-profile=normal`. The framework reported `successful=5000`, identical source fingerprint and identical final checksum for both implementations.

## Baseline and P0 result

| Backend | Median of 3 runs, ns/call | Individual runs, ns/call | Relative result |
|---|---:|---:|---:|
| C11 reference | 17,334.773 | 17,421.235; 15,187.819; 17,334.773 | Baseline |
| YASM x86-64 before P0 | 19,127.833–20,112.208 | 3-run range | 8–13% slower than C11 |
| YASM x86-64 after P0 | 245.408 | 250.442; 245.408; 242.864 | Approximately 98.6% lower latency than the C11 median |

The C11 samples contain one lower outlier, so the comparison is intentionally reported using the C11 median rather than the most favorable sample. The P0 result is not a single noisy improvement: all three ASM runs remained below 251 ns/call.

## Implemented optimization

The optimized ASM entry point adds a standalone one-word odd-modulus fast path. It validates pointers, complete-record overlap, lengths, modulus parity and the modulus lower bound before reading operands. It reduces the input once with hardware `div`, then executes binary extended Euclidean residue/coefficient updates in registers. The generic fixed-capacity path remains available for multiword or even-modulus inputs. Callee-saved registers are preserved, the destination is published only after success, and the zero-residue branch returns `BIGNUM_INVERSE_ERROR_NO_INVERSE` instead of looping.

The optimization is deliberately limited to the dominant measured one-word path. It does not claim that every multiword workload is faster. A follow-up benchmark matrix should measure `quarter`, `half` and `near-capacity` operands with a workload generator that preserves those logical lengths; the current adapter uses a fixed prime modulus to guarantee successful timing samples and collapses the generated value to one word.

## v0.1.0 candidate measurement

A fresh three-run measurement was performed after the v0.1.0 documentation and revision metadata update, using the same protocol as above. The reported workload was successful in all 5,000 iterations for both backends, with fingerprint `10444713935745760447` and checksum `15698918753894703398`.

| Backend | Run 1 | Run 2 | Run 3 | Median ns/call |
|---|---:|---:|---:|---:|
| C11 reference | 19,116.893 | 18,297.643 | 17,739.286 | 18,297.643 |
| YASM x86-64 P0 | 258.134 | 259.693 | 255.490 | 258.134 |

The ASM candidate is approximately 98.6% lower latency than the C11 median on this one-word profile. This measurement is reproducible for the tested workload but does not establish near-capacity performance; the documented 32-word baseline currently exposes a correctness gap and is excluded from speed claims.

## Acceptance evidence

The full five-binary ASM test suite passes after the P0 path was added: deterministic vectors, non-coprime/zero/error handling, randomized model checks, canary/transaction tests, eight-worker reentrancy and benchmark-adapter tests all report success. The P0 candidate also passed a dedicated 2,000-case timeout reproducer, proving that non-coprime random inputs terminate.
