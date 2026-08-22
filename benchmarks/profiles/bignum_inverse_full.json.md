# How-to: `bignum_inverse_full.json`

## Назначение

`bignum_inverse_full.json` — расширенная domain-specific matrix для анализа производительности binary extended Euclidean inverse. Она предназначена для подготовленного controlled run, а не для быстрого CI smoke. Manifest сохраняет все meaningful bignum axes: zero/mixed input and binary-euclid operation, operand word length, measurement boundary and near-capacity state.

The C11 `bench_matrix` runner from pinned `benchmark-framework v1.0.0` accepts the JSON document and launches project-owned ST/MT bignum adapter binaries. The runner writes a raw samples document; the C11 `benchmark_stats` tool parses it through public `json-lib` and emits a metrics/regression summary.

## Coverage

| Family | Profiles | What it isolates |
|---|---:|---|
| Zero path | 1 | zero-input inverse adapter path |
| One-word paths | 2 | one-word inverse paths with bounded operands |
| Quarter/half lengths | 4 | extended-Euclidean inverse costs at bounded multi-word sizes |
| Variable/mixed | 2 | Reproducible randomized and branch-diverse workload behavior |
| Near-capacity | 3 | valid inverse workloads near storage capacity |

The document declares **12 profiles**. A run with `R` repetitions therefore produces `12 × 2 × R` samples: one ST and one MT process per profile/repetition.

## Controlled full run

Use fixed seed, thread count, data-count and iteration counts when a result will become a baseline. The following command shows the expected C11 runner contract; Makefile integration will expose the same parameters after its separate approval.

```bash
libs/benchmark-framework/build/tools/bench_matrix \
  --manifest benchmarks/profiles/bignum_inverse_full.json \
  --output benchmarks/reports/bignum_inverse_full_matrix.json \
  --st-binary bin/bench_bignum_inverse \
  --mt-binary bin/bench_bignum_inverse_mt \
  --repetitions 7 \
  --iterations 200000000 \
  --mt-total-iterations 320000000 \
  --threads 2 \
  --warmup 10000 \
  --data-count 4096 \
  --seed 11400714819323198485 \
  --timeout-seconds 1800
```

Do not compare this result to data collected with different manifest contents, compiler configuration, CPU affinity, thread count or benchmark boundary. The JSON report records profile text, command/protocol outputs and individual timing samples so the conditions remain auditable.

## Review candidate metrics

Create a candidate summary first:

```bash
libs/benchmark-framework/build/tools/benchmark_stats \
  --input benchmarks/reports/bignum_inverse_full_matrix.json \
  --output benchmarks/reports/bignum_inverse_full_summary.json
```

After review, preserve the raw matrix JSON as the baseline because it contains all repetitions and profile metadata. Compare a later candidate as follows:

```bash
libs/benchmark-framework/build/tools/benchmark_stats \
  --input benchmarks/reports/candidate_full_matrix.json \
  --baseline benchmarks/reports/reviewed_full_matrix.json \
  --output benchmarks/reports/candidate_full_summary.json \
  --threshold-pct 5
```

A `regression:true` field means the candidate median exceeded both the configured threshold and robust MAD-based noise floor. A non-zero result with `missing_profiles` means the documents do not share complete profile/mode coverage and must not be treated as a valid comparison.

## Bignum transport vocabulary

`operation_kind must equal `binary-euclid`. It is not legal to substitute generic example values such as `xor` or `rotate`. The adapter validates these values before it initializes bignum state, therefore malformed profiles fail before their data become benchmark samples.

| `operation_kind` | Binary Euclidean GCD path |
|---|---|
| `binary-euclid` | guaranteed coprime inverse operation |
| `binary-euclid` | Deterministic representable sub-word amount |
| `binary-euclid` | Deterministic representable whole-word amount |
| `binary-euclid` | Deterministic representable whole-word-plus-bit amount |
| `binary-euclid` | Deterministic representable amount derived from seed/iteration |
| `binary-euclid` | Stable rotation through zero, bit, word and combined paths |
