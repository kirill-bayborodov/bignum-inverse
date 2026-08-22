/**
 * @file test_bignum_inverse_benchmark_adapter.c
 * @brief Deterministic tests for the bignum_inverse benchmark adapter.
 * @version 1.0.0
 * @details Validates profile vocabulary, deterministic callback state,
 * successful inverse operation and observable checksum behavior.
 */
#include "bignum_inverse_benchmark_adapter.h"
#include "bignum_inverse.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static benchmark_workload_t workload(void)
{
    return (benchmark_workload_t){ .data_mode = "custom", .input_kind = "nonzero",
        .operation_kind = "binary-euclid", .measure_mode = "kernel-only",
        .size_profile = "quarter", .capacity_profile = "normal", .seed = UINT64_C(1),
        .warmup = 2U, .data_count = 8U };
}

static void test_validation(void)
{
    benchmark_workload_t w = workload();
    assert(bignum_inverse_benchmark_validate_workload(&w) == BIGNUM_INVERSE_BENCHMARK_STATUS_SUCCESS);
    w.operation_kind = "invalid";
    assert(bignum_inverse_benchmark_validate_workload(&w) == BIGNUM_INVERSE_BENCHMARK_STATUS_INVALID_PROFILE);
    assert(bignum_inverse_benchmark_validate_workload(NULL) == BIGNUM_INVERSE_BENCHMARK_STATUS_NULL_ARGUMENT);
}

static void test_callbacks(void)
{
    benchmark_adapter_t adapter;
    benchmark_workload_t w = workload();
    unsigned char first[sizeof(bignum_t) * 3U];
    unsigned char second[sizeof(bignum_t) * 3U];
    assert(bignum_inverse_benchmark_adapter_init(NULL) == BIGNUM_INVERSE_BENCHMARK_STATUS_NULL_ARGUMENT);
    assert(bignum_inverse_benchmark_adapter_init(&adapter) == BIGNUM_INVERSE_BENCHMARK_STATUS_SUCCESS);
    assert(adapter.state_size == sizeof(first));
    memset(first, 0, sizeof(first)); memset(second, 0, sizeof(second));
    assert(adapter.initialize(first, 3U, &w, adapter.adapter_context) == BENCHMARK_ADAPTER_STATUS_SUCCESS);
    assert(adapter.initialize(second, 3U, &w, adapter.adapter_context) == BENCHMARK_ADAPTER_STATUS_SUCCESS);
    assert(memcmp(first, second, sizeof(first)) == 0);
    assert(adapter.operation(first, 7U, &w, adapter.adapter_context) == BENCHMARK_ADAPTER_STATUS_SUCCESS);
    assert(adapter.checksum(first, 7U, adapter.adapter_context) != 0U);
}

int main(void)
{
    puts("--- Starting bignum_inverse benchmark adapter tests ---");
    test_validation(); puts("test_validation: PASSED");
    test_callbacks(); puts("test_callbacks: PASSED");
    puts("--- All bignum_inverse benchmark adapter tests passed ---");
    return 0;
}
