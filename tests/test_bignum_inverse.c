/**
 * @file test_bignum_inverse.c
 * @brief Deterministic contract and correctness tests for bignum_inverse.
 * @version 1.0.0
 * @details Covers successful inverses, even and odd moduli, reduction of a,
 * non-coprime inputs, invalid arguments, overlap rejection, bad lengths and
 * transactional preservation of the destination on every failure.
 */
#include "bignum_inverse.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static void set_u64(bignum_t *v, uint64_t x)
{
    memset(v, 0, sizeof(*v));
    if (x != 0U) { v->words[0] = x; v->len = 1U; }
}

static uint64_t get_u64(const bignum_t *v)
{
    assert(v->len <= 1U);
    return v->len == 0U ? 0U : v->words[0];
}

static void test_success_vectors(void)
{
    static const uint64_t vectors[][3] = {
        {3U, 11U, 4U}, {17U, 3120U, 2753U}, {7U, 40U, 23U},
        {5U, 13U, 8U}, {1U, 2U, 1U}, {2U, 3U, 2U},
        {37U, 101U, 71U}, {123456789U, 1000000007U, 18633540U},
        {1000000008U, 1000000007U, 1U}
    };
    for (size_t i = 0U; i < sizeof(vectors) / sizeof(vectors[0]); ++i) {
        bignum_t a, m, result;
        set_u64(&a, vectors[i][0]); set_u64(&m, vectors[i][1]);
        assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_SUCCESS);
        assert(get_u64(&result) == vectors[i][2]);
        assert(((__uint128_t)vectors[i][0] * get_u64(&result)) % vectors[i][1] == 1U);
    }
    puts("test_success_vectors: PASSED");
}

static void test_no_inverse_and_zero(void)
{
    bignum_t a, m, result, original;
    set_u64(&a, 12U); set_u64(&m, 8U); memset(&result, 0xA5, sizeof(result)); original = result;
    assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_ERROR_NO_INVERSE);
    assert(memcmp(&result, &original, sizeof(result)) == 0);
    set_u64(&m, 0U);
    assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_ERROR_MODULUS_ZERO);
    assert(memcmp(&result, &original, sizeof(result)) == 0);
    puts("test_no_inverse_and_zero: PASSED");
}

static void test_invalid_arguments_and_overlap(void)
{
    bignum_t a, m, result, original;
    set_u64(&a, 3U); set_u64(&m, 11U); memset(&result, 0x5A, sizeof(result)); original = result;
    assert(bignum_inverse(NULL, &a, &m) == BIGNUM_INVERSE_ERROR_NULL_ARG);
    assert(bignum_inverse(&result, NULL, &m) == BIGNUM_INVERSE_ERROR_NULL_ARG);
    assert(bignum_inverse(&result, &a, NULL) == BIGNUM_INVERSE_ERROR_NULL_ARG);
    assert(bignum_inverse(&a, &a, &m) == BIGNUM_INVERSE_ERROR_OVERLAP);
    assert(bignum_inverse(&m, &a, &m) == BIGNUM_INVERSE_ERROR_OVERLAP);
    assert(memcmp(&result, &original, sizeof(result)) == 0);
    a.len = BIGNUM_CAPACITY + 1U;
    assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_ERROR_BAD_LENGTH);
    assert(memcmp(&result, &original, sizeof(result)) == 0);
    puts("test_invalid_arguments_and_overlap: PASSED");
}

static void test_reduction_and_boundary_moduli(void)
{
    bignum_t a, m, result;
    set_u64(&a, UINT64_MAX); set_u64(&m, 101U);
    assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_SUCCESS);
    assert(get_u64(&result) == 79U);
    set_u64(&a, 1U); set_u64(&m, 1U);
    assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_ERROR_NO_INVERSE);
    puts("test_reduction_and_boundary_moduli: PASSED");
}

/** @brief Runs all deterministic inverse contract and identity checks. */
int main(void)
{
    puts("--- Starting deterministic bignum_inverse tests ---");
    test_success_vectors();
    test_no_inverse_and_zero();
    test_invalid_arguments_and_overlap();
    test_reduction_and_boundary_moduli();
    puts("--- All deterministic bignum_inverse tests passed ---");
    return 0;
}
