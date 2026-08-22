# Variant B C11 report

## Scope

This report covers the C11 modular-coefficient implementation for odd moduli, the isolated inverse modulo `2^k` layer, and CRT recombination for general even moduli `m = 2^k * q` with odd `q > 1`.

## Correctness evidence

The official C11 suite passes with `0 / 5 failed`. It includes deterministic vectors, 2,000 model-fuzz cases, pure power-of-two modulus, near-capacity odd modulus, near-capacity even CRT modulus, canary/transaction checks, multithreaded calls, runner integration and benchmark-adapter checks.

An independent small-width oracle tested `k=1..20`, odd `q` values from 3 through 999, and odd inputs below 1000. It checked both successful inverses and `NO_INVERSE` for non-coprime pairs. Result: `CRT small oracle: PASSED`.

The near-capacity CRT regression uses `a=5`, `m=3*2^2040`, and checks the exact 32-word inverse pattern. It passes. The previous false-success defect for even `a` and even `m` was fixed by rejecting even input before CRT; the same 2,000-case fuzz suite now passes.

The isolated `mod 2^k` layer passes widths 1 through 128 bits and boundary widths through 2047 bits against a `__uint128_t` oracle. An in-place multiplication aliasing defect was found and corrected before integration.

## Benchmark

Controlled C11 CRT measurements used `a=5`, `m=3*2^(64*n-8)`, 2,000 successful calls per logical length, and `CLOCK_MONOTONIC` wall-clock timing.

| Logical length | Successful calls | C11 CRT ns/call |
|---:|---:|---:|
| 1 word | 2,000/2,000 | 8,678.162 |
| 2 words | 2,000/2,000 | 9,988.245 |
| 4 words | 2,000/2,000 | 11,652.545 |
| 8 words | 2,000/2,000 | 16,700.192 |
| 16 words | 2,000/2,000 | 26,396.441 |
| 32 words | 2,000/2,000 | 54,876.410 |

These are C11-only measurements. No ASM comparison is claimed because ASM variant B has not been implemented yet.

## Remaining work before ASM

The C11 path needs sanitizer and coverage reruns after the CRT integration, Doxygen/QG artifact review, and a commit on the `variant-b-c11` branch. Only after those checks should an ASM variant B design be proposed. The public v0.1.0 tag remains unchanged.
