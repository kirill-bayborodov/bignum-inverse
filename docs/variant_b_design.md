# Variant B design: modular-coefficient inverse

## Problem to solve

The v0.1.0 binary EEA stores signed Bezout magnitudes in fixed `BIGNUM_CAPACITY` records. A valid near-capacity inverse can require a coefficient state outside that private bound, causing a false `BIGNUM_INVERSE_ERROR_NO_INVERSE`. Increasing the signed state is variant A and increases stack pressure.

## Proposed representation

Variant B keeps coefficients reduced modulo the target modulus instead of storing growing signed magnitudes. For an odd modulus, the binary EEA coefficient update is exact in the residue ring: when a residue is even, an odd coefficient is transformed as `(x + m) / 2`; an even coefficient is divided directly. Subtraction updates use modular add/subtract. Every coefficient remains in `[0,m)`, so coefficient storage is bounded by the public capacity.

An even modulus cannot use that half rule directly. Adding an even modulus does not change the parity of an odd coefficient. For example, the relation `8 = 3*0 + 8*1` halves to `4`, which needs a coefficient of `m/2` rather than an integer coefficient of `m`. Therefore simply replacing signed coefficients with `x mod m` would be mathematically unsound for even moduli.

## Even-modulus strategy

For `m = 2^k * q` with q odd, compute the inverse in two rings and combine the results with CRT:

1. Extract `2^k` by counting low zero bits and shifting a private copy.
2. If `q > 1`, compute `a^{-1} mod q` with the modular-coefficient binary EEA. If `q == 1`, this component is omitted.
3. Compute `a^{-1} mod 2^k` using a bit-doubling Newton/Hensel recurrence, keeping every intermediate reduced to `2^k`.
4. Combine the two residues with `x = x_q + q * (((x_2 - x_q) * q^{-1}) mod 2^k)` and reduce once modulo m.
5. Publish only after the final range and congruence checks pass.

All temporaries remain bounded by at most two public-capacity records plus a small carry margin. The implementation must explicitly reject capacity overflow rather than expose a partial result.

## Why this is preferred

This preserves a binary EEA kernel for the odd component, removes signed coefficient growth, gives a proof-driven path for even moduli, and avoids changing the public API. It is more complex than variant A, but it addresses the actual mathematical limitation instead of only increasing the bound.

## Required validation before ASM

The C11 implementation must first pass deterministic vectors for odd/even moduli, powers of two, moduli with both 2-adic and odd factors, 2-word through 32-word near-capacity inputs, non-coprime inputs, transactional failure paths and a trusted Python/GMP-style oracle. Benchmark coverage must include each modulus class and logical lengths 1/2/4/8/16/32. Only after C11 correctness is established should the ASM variant be designed.

## Decision request

The CRT/Hensel decomposition above is the proposed interpretation of variant B. It is a substantial algorithmic change and should be accepted before C11 implementation begins.
