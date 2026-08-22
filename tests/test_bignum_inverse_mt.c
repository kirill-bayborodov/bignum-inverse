/**
 * @file test_bignum_inverse_mt.c
 * @brief Reentrancy test for bignum_inverse.
 * @version 1.0.0
 * @details Eight threads execute independent inverse calculations repeatedly;
 * each result is checked against the same mathematical identity.
 */
#include "bignum_inverse.h"
#include <assert.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>

/** @brief Number of independent worker threads used by the reentrancy test. */
#define THREAD_COUNT 8U
/** @brief Number of repeated inverse calls made by each worker. */
#define ITERATIONS 2000U

/** @brief Per-thread immutable inputs and failure flag. */
typedef struct inverse_thread_case {
    uint64_t a_value; /**< Input value whose inverse is computed. */
    uint64_t modulus_value; /**< Positive prime modulus used by the worker. */
    int failed; /**< Set non-zero if any call violates the expected contract. */
} inverse_thread_case_t;

static void set_u64(bignum_t *v, uint64_t x)
{
    *v = (bignum_t){ .words = { x }, .len = x != 0U ? 1U : 0U };
}

static void *inverse_worker(void *opaque)
{
    inverse_thread_case_t *test = opaque;
    for (size_t i = 0U; i < ITERATIONS; ++i) {
        bignum_t a, m, result;
        set_u64(&a, test->a_value); set_u64(&m, test->modulus_value);
        if (bignum_inverse(&result, &a, &m) != BIGNUM_INVERSE_SUCCESS ||
            ((__uint128_t)test->a_value * result.words[0]) % test->modulus_value != 1U) {
            test->failed = 1;
            return NULL;
        }
    }
    return NULL;
}

/** @brief Creates workers, joins them and checks all reentrancy results. */
int main(void)
{
    pthread_t threads[THREAD_COUNT];
    inverse_thread_case_t cases[THREAD_COUNT];
    for (size_t i = 0U; i < THREAD_COUNT; ++i) {
        cases[i] = (inverse_thread_case_t){ 3U + 2U * i, 1000000007U, 0 };
        assert(pthread_create(&threads[i], NULL, inverse_worker, &cases[i]) == 0);
    }
    for (size_t i = 0U; i < THREAD_COUNT; ++i) assert(pthread_join(threads[i], NULL) == 0);
    for (size_t i = 0U; i < THREAD_COUNT; ++i) assert(cases[i].failed == 0);
    puts("test_bignum_inverse_mt: PASSED");
    return 0;
}
