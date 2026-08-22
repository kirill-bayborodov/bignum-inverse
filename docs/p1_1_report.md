# P1.1 report: fast significant-word discovery

## Decision

No P1.1 code change is accepted in this iteration. The public contract and C11 reference remain unchanged, and the P0 ASM implementation remains the only modified backend.

## Investigation

The generic ASM source is a standalone translation of the C11 implementation. The private normalization helper is inlined into several arithmetic blocks; the assembled object has no callable `inverse_normalize` symbol that can be replaced without changing control-flow targets and stack-frame assumptions. A local replacement with `bsr`/`lzcnt` would therefore require either a full hand rewrite of the generic kernel or a C refactor that changes the reference implementation and its measured baseline.

The one-word odd-modulus path is already specialized by P0 and does not scan a fixed-capacity tail. Adding a bit-scan there would add instructions without removing work. The multiword path needs a representation-aware hand rewrite because `len`, carry propagation, and zero-tail clearing are coupled by the reduction invariant.

## Validation

The attempted active-length C11 reduction was rejected after the full suite returned `5 / 5` failures, including the `3 mod 11` vector. The C11 source was restored to the v0.0.0 implementation. The P0 ASM candidate still passes the complete regression suite and the 2,000-case timeout reproducer.

## Recommendation

Keep P1.1 as a documented non-change and proceed to P1.2 only after explicit approval. P1.2 can be implemented independently and safely by improving hot/cold branch layout and moving validation/error exits out of the success path. A later P1.3 hand rewrite can then introduce `bsr`-based normalization together with dedicated multiword loops, where the optimization has enough work to amortize its complexity.
