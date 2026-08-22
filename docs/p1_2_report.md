# P1.2 report: branch layout and cold-path alignment

## Candidate

The candidate aligned the frequently revisited fast-path binary-EEA loop and the odd-residue subtraction block to 16-byte boundaries using NOP padding. No arithmetic, ABI, validation or error semantics were changed.

## Validation

YASM assembled the candidate successfully. The complete five-binary ASM regression passed with `0 / 5 failed`, including deterministic, randomized, transactional, MT and benchmark-adapter tests.

## Benchmark

The required controlled workload remained `seed=123456789`, `warmup=100`, `data-count=8`, `iterations=5000`, `measure-mode=kernel-only`, `size-profile=one`, and `capacity-profile=normal`.

| Candidate | Run 1 | Run 2 | Run 3 | Median |
|---|---:|---:|---:|---:|
| P0 ASM | 250.442 | 245.408 | 242.864 | 245.408 |
| P1.2 aligned ASM | 261.828 | 249.723 | 247.407 | 249.723 |

The aligned candidate is approximately 1.8% slower by median than P0 and therefore fails the acceptance criterion of measurable improvement. It was reverted. The working tree contains no accepted P1.2 code change; this report is retained as evidence for the decision.

## Conclusion

The current fast path is already compact enough that padding does not improve instruction delivery on this machine. Further branch-layout work should wait until P1.3 introduces a real multiword hand-tuned kernel with stable workload classes; optimizing layout before reducing memory traffic is not justified.
