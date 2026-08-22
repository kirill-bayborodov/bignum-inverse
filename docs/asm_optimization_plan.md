# Hand-tuned ASM optimization plan

The v0.2.1 correctness release is the immutable baseline. The current ASM is a compiler-generated translation of the C11 variant B and is functionally correct but slower than C11 across the matrix.

The optimization will preserve the generated implementation as `bignum_inverse_generic`. A small hand-written public dispatcher will validate the ABI-visible arguments and select a register-resident one-word odd-modulus kernel only when `a`, `modulus` and `result` are non-overlapping records, both logical lengths are one word, the modulus is odd and the modulus fits one 64-bit word. All other inputs will branch to the unchanged generic implementation.

The fast kernel will use a binary extended-Euclidean recurrence with scalar residues and modular coefficients in registers. It will preserve SysV callee-saved registers, keep output transactional by writing the result only after gcd==1, and explicitly terminate on zero residues. No `-march=native`, libc call, Makefile change or CI change is permitted.

Acceptance requires the existing five-binary ASM suite, the C11 suite, sanitizer checks, overlap/transaction tests, a one-word benchmark and the full 18-point variant-B matrix. A candidate is rejected if any checksum differs or if the fast path is not faster than the v0.2.1 generic ASM on its target workload. Multiword and general CRT paths remain on the generated fallback until a separate hand-tuned implementation is justified by measurements.
