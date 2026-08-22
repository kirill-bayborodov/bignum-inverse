/**
 * @file bignum_inverse_benchmark_adapter.h
 * @brief Benchmark-framework binding for bignum_inverse workloads.
 * @version 1.0.0
 * @details Maps generic benchmark profiles to deterministic `(a, modulus)`
 * records and exposes typed adapter callbacks without global mutable state.
 */
#ifndef BIGNUM_INVERSE_BENCHMARK_ADAPTER_H
#define BIGNUM_INVERSE_BENCHMARK_ADAPTER_H
#include <benchmark_framework.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef enum bignum_inverse_benchmark_status {
    BIGNUM_INVERSE_BENCHMARK_STATUS_SUCCESS = 0,
    BIGNUM_INVERSE_BENCHMARK_STATUS_NULL_ARGUMENT = 1,
    BIGNUM_INVERSE_BENCHMARK_STATUS_INVALID_PROFILE = 2,
    BIGNUM_INVERSE_BENCHMARK_STATUS_OPERATION_ERROR = 3
} bignum_inverse_benchmark_status_t;

bignum_inverse_benchmark_status_t bignum_inverse_benchmark_adapter_init(
    benchmark_adapter_t *adapter);
bignum_inverse_benchmark_status_t bignum_inverse_benchmark_validate_workload(
    const benchmark_workload_t *workload);
#ifdef __cplusplus
}
#endif
#endif
