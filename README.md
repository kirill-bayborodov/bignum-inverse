# bignum-inverse

**Release candidate:** v0.2.1 — C11/ASM modular-coefficient and CRT/Hensel correctness parity

[![C/ASM CI](https://github.com/kirill-bayborodov/bignum-inverse/actions/workflows/ci.yml/badge.svg)](https://github.com/kirill-bayborodov/bignum-inverse/actions/workflows/ci.yml)
[![GitHub release](https://img.shields.io/github/v/release/kirill-bayborodov/bignum-inverse?label=release)](https://github.com/kirill-bayborodov/bignum-inverse/releases/latest)

`bignum-inverse` computes the modular multiplicative inverse of an unsigned `bignum_t` value and a positive modulus with the signed binary extended Euclidean algorithm. The repository contains two implementations with the same typed public contract: a portable C11 reference implementation in `src/bignum_inverse.c` and a standalone YASM x86-64 implementation in `src/bignum_inverse.asm`. The assembly path conforms to the System V AMD64 ABI and does not call C functions. Its P0 path specializes one-word odd moduli with register-resident binary EEA state; multiword and even-modulus inputs use the generic fixed-capacity path.

The operation is transactional. It validates all pointers, lengths and result/input ranges before touching the destination. Variant B uses modular coefficients for odd moduli, Newton inversion modulo `2^k` and CRT recombination for general even moduli, while retaining a guarded signed-pair fallback. No heap allocation or mutable global state is used.

## Distribution

The repository uses source submodules for the arithmetic primitives and a downloaded distribution for the generic benchmark framework. The official CI workflow downloads the latest successful `dist` artifact of `benchmark-framework` into `libs/benchmark-framework/dist`; local development should use the same layout.

| Component | Location | Role |
|---|---|---|
| `bignum-core` | `libs/bignum-core` | Defines `bignum_t`, `BIGNUM_CAPACITY` and core status types |
| `bignum-cmp` | `libs/bignum-cmp` | Compares normalized multiword operands |
| `bignum-shift-right` | `libs/bignum-shift-right` | Removes powers of two from private operands |
| `bignum-sub-bignum` | `libs/bignum-sub-bignum` | Subtracts the smaller odd operand from the larger one |
| `benchmark-framework` | `libs/benchmark-framework/dist` | Provides benchmark-core, runners, profiles and matrix tools |

Clone with source submodules:

```bash
git clone --recurse-submodules https://github.com/kirill-bayborodov/bignum-inverse.git
cd bignum-inverse
git submodule update --init --recursive
```

For a local benchmark-framework distribution, download the latest successful `dist` artifact from the `benchmark-framework` repository and extract it directly into `libs/benchmark-framework/dist`. Do not modify the official CI workflow or Makefile to accommodate a local installation.

## Features

- **Binary extended Euclidean algorithm:** removes powers of two, maintains Bezout coefficients and uses subtraction rather than general division in the convergence loop.
- **Two equivalent backends:** C11 reference source and standalone YASM x86-64 production source share one header and one test suite.
- **ASM correctness parity:** standalone YASM matches the C11 modular-coefficient, power-of-two and CRT/Hensel paths with the same typed ABI and transaction guarantees.
- **ASM P0 fast path:** one-word odd-modulus calls avoid generic record traffic while preserving the same status and transactional ABI.
- **Typed status API:** named validation, overlap, zero-modulus, no-inverse and internal-error statuses avoid anonymous integer contracts.
- **Transactional output:** `result` is unchanged for every documented failure status.
- **Fixed-capacity arithmetic:** the implementation is bounded by `BIGNUM_CAPACITY` and performs no allocation.
- **Normalized representation:** successful results are canonical residues with `0 <= result < modulus`; zero has `len == 0` and non-zero values have a non-zero most-significant word.
- **Aliasing contract:** the two read-only inputs may alias each other; `result` must not overlap either input.
- **Deterministic verification:** deterministic, model/fuzz, MT, runner and benchmark-adapter tests are included.
- **Benchmark-framework integration:** ST/MT adapters generate deterministic two-operand inverse workloads and observable checksums.
- **QG-oriented documentation:** Doxygen comments, source history, profile documentation and build/test instructions are kept with the module.

## Dependencies

| Dependency | Purpose |
|---|---|
| `make` | Official build, test, lint, benchmark, install and distribution targets |
| `gcc` | C11 compilation and linking |
| `yasm` | x86-64 assembly compilation |
| `cppcheck` | Static analysis through `make lint` |
| `valgrind` | Helgrind race detection |
| `perf` | Optional sampling and counter benchmarks |
| `taskset` | Benchmark CPU affinity |
| `pthread` | MT tests and benchmark runners |

The project uses `BIGNUM_CAPACITY == 32`, so each value can contain up to 2048 bits. The assembly implementation is written for the System V AMD64 ABI and is not a Windows x64 ABI implementation.

## API

The public API is declared in [`include/bignum_inverse.h`](include/bignum_inverse.h):

```c
typedef enum bignum_inverse_status {
    BIGNUM_INVERSE_SUCCESS = 0,
    BIGNUM_INVERSE_ERROR_NULL_ARG = -1,
    BIGNUM_INVERSE_ERROR_BAD_LENGTH = -2,
    BIGNUM_INVERSE_ERROR_OVERLAP = -3,
    BIGNUM_INVERSE_ERROR_MODULUS_ZERO = -4,
    BIGNUM_INVERSE_ERROR_NO_INVERSE = -5,
    BIGNUM_INVERSE_ERROR_INTERNAL = -6
} bignum_inverse_status_t;

bignum_inverse_status_t bignum_inverse(
    bignum_t *result,
    const bignum_t *a,
    const bignum_t *modulus);
```

### Contract

| Condition | Return value | Destination behavior |
|---|---|---|
| `result`, `a` or `modulus` is `NULL` | `BIGNUM_INVERSE_ERROR_NULL_ARG` | `result` is not dereferenced; if non-NULL it is unchanged |
| `a->len` or `modulus->len` exceeds `BIGNUM_CAPACITY` | `BIGNUM_INVERSE_ERROR_BAD_LENGTH` | `result` is unchanged |
| `result` overlaps `a` or `modulus` | `BIGNUM_INVERSE_ERROR_OVERLAP` | `result` is unchanged |
| Valid coprime operands | `BIGNUM_INVERSE_SUCCESS` | `result` is the canonical inverse and is normalized |
| `gcd(a, modulus) != 1` or `modulus <= 1` | `BIGNUM_INVERSE_ERROR_NO_INVERSE` | `result` is unchanged |

The inputs are interpreted as unsigned little-endian word arrays. A zero value is represented by `len == 0`; non-zero inputs should be normalized before the call. The function does not modify either input. The read-only inputs may be the same object, but the output record must be a separate, non-overlapping object.

For example:

```c
#include "bignum_inverse.h"

bignum_inverse_status_t application_inverse(
    bignum_t *result,
    const bignum_t *a,
    const bignum_t *modulus)
{
    return bignum_inverse(result, a, modulus);
}
```

## Build and test

The official Makefile is intentionally unchanged. Build the selected backend and all source submodules with:

```bash
make clean
make build CONFIG=release
```

The production object is written to `build/bignum_inverse.o`. Select the backend explicitly when comparing implementations:

```bash
make build CONFIG=release USE_ASM=no   # C11 reference
make build CONFIG=release USE_ASM=yes  # YASM x86-64
```

Run the complete deterministic, extended, MT, distribution-runner and adapter suite:

```bash
make test CONFIG=release USE_ASM=no
make test CONFIG=release USE_ASM=yes
```

The expected summary is:

```text
=== Summary: 0 / 5 failed ===
```

Run static and dynamic checks:

```bash
make lint
make test_sanitize SAN=address CONFIG=release USE_ASM=no
make test_sanitize SAN=undefined CONFIG=release USE_ASM=no
make test_helgrind CONFIG=release USE_ASM=no
```

The test files are organized as follows:

| File | Scope |
|---|---|
| `tests/test_bignum_inverse.c` | Deterministic identities, known values, normalization, invalid inputs and alias rejection |
| `tests/test_bignum_inverse_extra.c` | Deterministic 64-bit model fuzzing, canary preservation and transactional failures |
| `tests/test_bignum_inverse_mt.c` | Reentrant independent-object calls across eight worker threads |
| `tests/test_bignum_inverse_runner.c` | Distribution-linkage and public-header smoke test |
| `tests/benchmark_adapter/test_bignum_inverse_benchmark_adapter.c` | Workload validation, deterministic state generation, operation callback and checksum |

The artifact-level test checklist, template comparison and coverage interpretation are in [`docs/test_qg_audit.md`](docs/test_qg_audit.md). The reproducible C11 gcov source report is [`docs/coverage/bignum_inverse.c.gcov`](docs/coverage/bignum_inverse.c.gcov).

## Benchmarks

The benchmark sources are:

```text
benchmarks/bench_bignum_inverse.c
benchmarks/bench_bignum_inverse_mt.c
benchmarks/adapter/bignum_inverse_benchmark_adapter.c
benchmarks/profiles/bignum_inverse_standard.json
benchmarks/profiles/bignum_inverse_full.json
```

The adapter state contains two immutable input records and one result record. For successful benchmark measurements it generates a fixed prime modulus and a non-zero coprime input. It accepts `zero`, `nonzero` and `mixed` input kinds, `binary-euclid` operation kind, `end-to-end` or `kernel-only` measurement, and `one`, `quarter`, `half`, `variable` or `near-capacity` size profiles. Successful runners print deterministic seed/fingerprint information, operation counts, elapsed time, nanoseconds per call and the final `Benchmark finished.` marker.

| Data mode | Generated operands | Purpose |
|---|---|---|
| `all_zero` | The generator substitutes a valid non-zero fallback pair | Exercises the adapter's zero-input selection path without allowing callback failures to contaminate timing |
| `all_nonzero` | Fixed prime modulus and normalized coprime input | Measures the normal binary inverse workload |
| `mixed` | Alternates generated input selection while retaining a valid coprime pair | Measures input-selection branch mixing |

### Single-thread CLI

```text
bin/bench_bignum_inverse \
  [--data-mode all_zero|all_nonzero|mixed] \
  [--input-kind zero|nonzero|mixed] \
  [--operation-kind binary-euclid|gcd|gcd-mixed] \
  [--measure-mode end-to-end|kernel-only] \
  [--size-profile one|quarter|half|variable|near-capacity] \
  [--capacity-profile normal|near-capacity] \
  [--iterations N] [--warmup N] [--data-count N] [--seed N]
```

Example reproducible run:

```bash
BIGNUM_BENCH_ITERATIONS=1000 \
BIGNUM_BENCH_SEED=123456789 \
./bin/bench_bignum_inverse \
  --input-kind nonzero --operation-kind binary-euclid \
  --measure-mode end-to-end --size-profile half \
  --capacity-profile normal
```

### Multithread CLI

```text
bin/bench_bignum_inverse_mt \
  [--threads N] [--total-iterations N] \
  [--data-mode all_zero|all_nonzero|mixed] \
  [--input-kind zero|nonzero|mixed] \
  [--operation-kind binary-euclid|gcd|gcd-mixed] \
  [--measure-mode end-to-end|kernel-only] \
  [--size-profile one|quarter|half|variable|near-capacity] \
  [--capacity-profile normal|near-capacity]
```

Use identical seed, workload profile and total work when comparing ST and MT or C11 and ASM. For a short MT smoke run:

```bash
BIGNUM_BENCH_MT_TOTAL_ITERATIONS=1000 \
BIGNUM_BENCH_SEED=123456789 \
./bin/bench_bignum_inverse_mt \
  --threads 2 --total-iterations 1000 \
  --input-kind nonzero --operation-kind binary-euclid \
  --size-profile quarter --capacity-profile normal
```

### Matrix profiles

The project-specific JSON manifests are validated before benchmark execution. `bignum_inverse_standard.json` is the short regression matrix; `bignum_inverse_full.json` exercises all documented size, input, measurement and capacity combinations. Each manifest has a `.json.md` companion that documents its vocabulary and intended use.

```bash
make bench_matrix CONFIG=release \
  BENCH_MATRIX_TOOL=libs/benchmark-framework/dist/tools/bench_matrix \
  BENCH_STATS_TOOL=libs/benchmark-framework/dist/tools/benchmark_stats \
  BENCH_MATRIX_PROFILE=benchmarks/profiles/bignum_inverse_standard.json \
  BENCH_MATRIX_REPETITIONS=3 \
  BENCH_MATRIX_ITERATIONS=1000 \
  BENCH_MATRIX_MT_TOTAL_ITERATIONS=1000 \
  REPORT_NAME=gcd_smoke
```

## Perf workflow

Use the standard benchmark target on a host with a kernel-compatible `perf` and supported PMU events:

```bash
make bench CONFIG=release REPORT_NAME=gcd_baseline DATA_MODE=all_nonzero
```

For cloud environments where hardware PMU events are unavailable, use the software-event target:

```bash
make bench_cl CONFIG=release \
  REPORT_NAME=gcd_cloud_smoke \
  PERF_RUNS=1 \
  BENCH_ITERATIONS=1000 \
  BENCH_MT_TOTAL_ITERATIONS=1000
```

The Makefile may require `/usr/local/bin/perf`; set the existing `PERF` variable to a kernel-compatible binary rather than changing the Makefile. Keep compiler, CPU affinity, seed, input mode, profile, thread count and total work constant for a fair comparison. Hardware-counter failures in restricted sandboxes are environment limitations, not benchmark correctness failures.

## Installation and distribution

Build the object-file installation layout:

```bash
make install CONFIG=release
```

Create the project distribution:

```bash
make dist CONFIG=release
```

Remove generated artifacts without changing source submodules:

```bash
make clean
```

## Linking the object file

Build the desired backend and link the object with the core and arithmetic dependency objects produced by the official Makefile:

```bash
make build CONFIG=release USE_ASM=yes
gcc your_app.c \
  build/bignum_inverse.o \
  build/bignum_core.o \
  build/bignum_cmp.o \
  build/bignum_shift_right.o \
  build/bignum_sub_bignum.o \
  -I./include \
  -I./libs/bignum-core/include \
  -I./libs/bignum-cmp/include \
  -I./libs/bignum-shift-right/include \
  -I./libs/bignum-sub-bignum/include \
  -o your_app
```

For distribution consumers, prefer the static/object package generated by `make dist CONFIG=release` and retain the public header and dependency include layout shipped by that package.

## Contributing

Changes must preserve the typed C11/YASM API contract, the transactional destination guarantee, the input aliasing rules and normalized representation. New behavior requires deterministic and model-based tests, MT coverage where relevant, benchmark-adapter coverage and updated Doxygen/QG documentation.

Before submitting a change, run at minimum:

```bash
git diff --check
make clean
make test CONFIG=release USE_ASM=no
make test CONFIG=release USE_ASM=yes
make lint
make test_sanitize SAN=address CONFIG=release USE_ASM=no
make test_sanitize SAN=undefined CONFIG=release USE_ASM=no
make test_helgrind CONFIG=release USE_ASM=no
make install CONFIG=release
make dist CONFIG=release
```

Performance changes should include reproducible ST and MT measurements for matching workload sizes, seeds, data modes and backend selection. Do not modify the official Makefile or CI workflow without explicit approval.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
