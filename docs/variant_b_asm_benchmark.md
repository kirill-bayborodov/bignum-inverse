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

## 2026-08-22: P1 candidate 1 — one-word scalar dispatcher

The candidate was validated with the complete release test suite: deterministic, extended fuzz, power-of-two, near-capacity CRT/odd, canary/transaction, multithreaded and benchmark-adapter tests all passed (`0 / 5 failed`).

The штатный benchmark command could not collect `cache-misses:u` because that hardware event is unavailable in the sandbox. For a valid controlled comparison, both binaries were run with the same workload and `perf stat -e task-clock -r 5`.

| Implementation | Workload | Mean elapsed | Mean task-clock | Result |
|---|---|---:|---:|---|
| v0.2.1 generated ASM baseline | mixed, random, inverse, one-word, 64 records, 1000 iterations | 1.0581 ms | 0.76 ms | reference |
| P1 candidate: hand-tuned scalar dispatcher/kernel | identical | 1.3013 ms | 0.91 ms | 22.9% slower elapsed; rejected |

The candidate is retained locally only for diagnosis and is not a release candidate. The regression is attributable to the five-register save/restore prologue and the scalar binary recurrence not yet amortizing its dispatch cost. The next step is to reduce the hot-path prologue and remove avoidable state transitions; no Makefile or CI changes are required.

## P1 candidate 2 — caller-saved register-only kernel

After removing the callee-saved register prologue, the candidate passed the complete release suite (`0 / 5 failed`). The controlled C11/ASM benchmark used identical `mixed`, `inverse`, `end-to-end`, seed 1, warmup 5 and checksum/fingerprint validation.

| Size profile | C11 ns/call | ASM candidate ns/call | ASM/C11 | Checksums |
|---|---:|---:|---:|---|
| one | 6,782.781 | 240.095 | 0.035x | identical |
| quarter | 6,907.297 | 249.917 | 0.036x | identical |
| half | 6,776.441 | 266.463 | 0.039x | identical |
| near-capacity | 7,753.600 | 317.550 | 0.041x | identical |

The current benchmark adapter deliberately normalizes `a.len` to one word for its inverse workload. Consequently, this matrix validates dispatch overhead and one-word performance across profile labels, but it is **not** evidence of a multiword optimization. The pre-existing 18-point matrix remains the authoritative multiword/generic-path comparison. Candidate 2 is a valid performance improvement for the one-word odd-modulus workload and leaves all other inputs on the correctness-preserving generated fallback.

## Sanitizer gate for optimization checkpoint

Because the immutable Makefile did not activate its `SAN` argument (`SAN=(none)` was reported), the inverse test sources were compiled manually with `-fsanitize=address -fno-omit-frame-pointer` and executed with leak detection enabled. Deterministic, extended fuzz, multithreaded and runner tests all exited successfully; no AddressSanitizer error or leak was reported.

## Multiword optimization step 1 — inverse of 2 modulo odd m

A dedicated register-resident path now handles `a=2` with an odd modulus of 2–32 words. Since `2^{-1} mod m = (m+1)/2`, the implementation performs one in-place copy, carry-propagating increment and right shift, while preserving the generated Variant B fallback for all other multiword inputs. The overflow from `m+1` is retained as a virtual high word during the shift.

| Words | C11 ns/call | ASM step 1 ns/call | ASM/C11 | Checksums |
|---:|---:|---:|---:|---|
| 1 | 2,820.072 | 28.600 | 0.010x | identical |
| 2 | 2,754.250 | 54.127 | 0.020x | identical |
| 4 | 2,823.528 | 54.068 | 0.019x | identical |
| 8 | 2,954.688 | 49.680 | 0.017x | identical |
| 16 | 2,906.008 | 50.764 | 0.017x | identical |
| 32 | 2,876.275 | 93.947 | 0.033x | identical |

The independent harness used odd moduli `2^(64n)-1`, `2^(64n)-3` and an alternating-word odd modulus, with 1,000 calls per size. A dedicated expected-value test covered every length from 2 through 32 and all three modulus classes under AddressSanitizer with leak detection; it passed without diagnostics. The full five-binary release suite also passed with `0 / 5 failed`.

This is a targeted multiword optimization, not yet a general multiword EEA optimization. The next candidate should address the common odd-modulus path for arbitrary `a` while retaining this constant-time-specialized case and the generated fallback.

## Multiword optimization step 2 — scalar a=7

The next targeted path handles arbitrary odd moduli of 2–32 words when `a=7`. It computes `m mod 7` using the base-2^64 recurrence, selects `t` such that `t*m+1` is divisible by 7, and evaluates `(t*m+1)/7` with a register-resident word multiply/divide pass. The generated Variant B implementation remains the fallback for other scalar values and all general multiword operands.

| Words | C11 ns/call | ASM step 2 ns/call | ASM/C11 | Checksums |
|---:|---:|---:|---:|---|
| 1 | 7,722.120 | 116.069 | 0.015x | identical |
| 2 | 12,977.636 | 45.448 | 0.004x | identical |
| 4 | 25,852.565 | 49.813 | 0.002x | identical |
| 8 | 47,458.784 | 89.857 | 0.002x | identical |
| 16 | 108,137.497 | 173.849 | 0.002x | identical |
| 32 | 251,955.744 | 450.943 | 0.002x | identical |

The full release suite passed with `0 / 5 failed`. The dedicated multiword correctness harness passed all lengths 2–32 under AddressSanitizer with leak detection. During development, two ABI defects were found and corrected: callee-saved registers are now preserved before modification, and the scalar remainder recurrence correctly accounts for `2^64 mod 7 = 2`.

## Multiword optimization step 3 — scalar a=3

A third targeted path handles arbitrary odd 2–32-word moduli for `a=3`. It scans `m mod 3`, selects `t=1` or `t=2`, and computes `(t*m+1)/3` using the same register-resident multiply/divide structure. Moduli divisible by 3 correctly return `BIGNUM_INVERSE_ERROR_NO_INVERSE` without modifying the destination.

| Words | C11 ns/call | ASM step 3 ns/call | ASM/C11 | Checksums |
|---:|---:|---:|---:|---|
| 2 | 16,347.785 | 61.904 | 0.004x | identical |
| 4 | 29,936.382 | 77.403 | 0.003x | identical |
| 8 | 58,169.775 | 91.240 | 0.002x | identical |
| 16 | 115,005.245 | 173.748 | 0.002x | identical |
| 32 | 260,384.954 | 404.078 | 0.002x | identical |

The full release suite passed with `0 / 5 failed`. Valid odd moduli were checked for lengths 2–32 under AddressSanitizer with leak detection, and the corresponding `m mod 3 == 0` cases were explicitly verified to return NO_INVERSE transactionally.
