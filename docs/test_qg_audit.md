# bignum_inverse test and QG audit

## Scope

This audit covers every project-owned test artifact for the typed `bignum_inverse` API. The same source-level tests are linked once against the C11 reference object and once against the standalone YASM object. The destination contract is transactional: every documented failure leaves the caller-owned result byte-identical.

| Artifact | Covered scenarios | Oracle or acceptance criterion |
|---|---|---|
| `tests/test_bignum_inverse.c` | Known inverses, odd/even modulus, input reduction, modulus one/zero, non-coprime values, NULL, bad length, exact alias and transactional preservation | Exact expected residues and named status codes |
| `tests/test_bignum_inverse_extra.c` | 2,000 deterministic pseudo-random 64-bit cases, successful and non-coprime branches, canaries and unchanged output | Euclidean `gcd` model plus `a * result mod modulus == 1` |
| `tests/test_bignum_inverse_mt.c` | Eight independent workers and repeated calls | Every result satisfies the modular identity; no shared mutable state |
| `tests/test_bignum_inverse_runner.c` | Public-header and linkage smoke test | Known `3^-1 mod 11 == 4` |
| `tests/benchmark_adapter/test_bignum_inverse_benchmark_adapter.c` | Profile vocabulary, deterministic state, operation callback and checksum | Named adapter statuses and identical same-seed state |

## Executed checks

The following commands are the reproducible verification sequence:

```bash
make clean
make test CONFIG=release USE_ASM=no
make test CONFIG=release USE_ASM=yes
make test_sanitize CONFIG=debug USE_ASM=no SAN=address
```

All completed runs reported `=== Summary: 0 / 5 failed ===`; the sanitizer run reported `tests=5, failed=0, sanitizer_issues=0`.

The C11 source coverage run used GCC `--coverage` and executed the deterministic, extra and MT binaries. The combined source report reached **100.00% line coverage** in the deterministic and extra passes; the aggregate MT-only pass was lower because it intentionally exercises the reentrant success path only. The retained report is `docs/coverage/bignum_inverse.c.gcov`.

## Review conclusions

The tests do not include an invalid overlapping pointer fabricated by byte-offset arithmetic because the public contract rejects any result/input record overlap before dereference; exact aliasing is the portable and deterministic representation of that forbidden class. The benchmark adapter deliberately uses a fixed prime modulus and coprime input so benchmark failure statuses cannot be confused with measured operation cost.
