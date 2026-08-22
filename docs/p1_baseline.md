# P1 optimization baseline

## Revision and scope

The baseline is release tag `v0.0.0`, whose commit is `4235c9b5c501228496e0233a4408f876abfc4f49`. The local `main` and `origin/main` point to that commit, and the working tree was clean before P1 work. Makefile and CI are outside the review scope.

## Current bottlenecks

The P0 release already specializes one-word odd moduli. Remaining cost is concentrated in the generic path: repeated scans of fixed-capacity records during normalization and zero-tail clearing, branch-heavy generated compare/subtract/shift helpers, and cold validation/error code sharing layout with the hot success path. The current benchmark adapter primarily exercises the one-word workload, so it cannot establish multiword performance.

| Candidate | Priority | Risk | Planned order |
|---|---:|---:|---:|
| Fast significant-word discovery with `bsr`/bit-scan and active-length bounds | P1.1 | Low | First |
| Hot/cold branch layout and early cold-path separation | P1.2 | Low–medium | Second |
| Hand-tuned multiword compare/subtract/halve loops | P1.3 | Medium–high | Third |

P1.1 will be accepted only if the complete shared test suite remains green and the generic/multiword benchmark does not regress. Each optimization is measured against both C11 and ASM using the same workload and protocol before proceeding.
