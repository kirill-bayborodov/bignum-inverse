/**
 * @file test_bignum_inverse_extra.c
 * @brief Extended randomized and memory-safety tests for bignum_inverse.
 * @version 1.0.0
 * @details Exercises 2,000 deterministic pseudo-random 64-bit inputs, both
 * parity classes of modulus, canonical output, canary preservation and the
 * transactional failure contract.
 */
#include "bignum_inverse.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint64_t next_random(uint64_t *state)
{
    *state ^= *state << 7U; *state ^= *state >> 9U; *state ^= *state << 8U;
    return *state;
}

static void set_u64(bignum_t *v, uint64_t x)
{
    memset(v, 0, sizeof(*v));
    if (x != 0U) { v->words[0] = x; v->len = 1U; }
}

static uint64_t gcd64(uint64_t a, uint64_t b)
{
    while (b != 0U) { const uint64_t t = a % b; a = b; b = t; }
    return a;
}

static void test_fuzz_against_u64_model(void)
{
    uint64_t state = UINT64_C(0x9e3779b97f4a7c15);
    for (size_t i = 0U; i < 2000U; ++i) {
        const uint64_t modulus = (next_random(&state) % UINT64_C(0x7ffffffffffffffe)) + 2U;
        const uint64_t a = next_random(&state);
        bignum_t av, mv, out;
        set_u64(&av, a); set_u64(&mv, modulus);
        const bignum_inverse_status_t status = bignum_inverse(&out, &av, &mv);
        if (gcd64(a, modulus) == 1U) {
            assert(status == BIGNUM_INVERSE_SUCCESS);
            assert(out.len <= 1U && out.words[0] < modulus);
            assert((__uint128_t)a * out.words[0] % modulus == 1U);
        } else {
            assert(status == BIGNUM_INVERSE_ERROR_NO_INVERSE);
        }
    }
    puts("test_fuzz_against_u64_model: PASSED");
}

static void test_canaries_and_transaction(void)
{
    struct guarded { uint64_t before; bignum_t result; uint64_t after; } box;
    box.before = UINT64_C(0x1122334455667788); box.after = UINT64_C(0x8877665544332211);
    memset(&box.result, 0xCC, sizeof(box.result));
    bignum_t a = { .words = { 12U }, .len = 1U };
    bignum_t m = { .words = { 8U }, .len = 1U };
    bignum_t original = box.result;
    assert(bignum_inverse(&box.result, &a, &m) == BIGNUM_INVERSE_ERROR_NO_INVERSE);
    assert(box.before == UINT64_C(0x1122334455667788));
    assert(box.after == UINT64_C(0x8877665544332211));
    assert(memcmp(&box.result, &original, sizeof(original)) == 0);
    puts("test_canaries_and_transaction: PASSED");
}

/** @brief Runs deterministic model-fuzz and transactional memory checks. */
int main(void)
{
    puts("--- Starting extended bignum_inverse tests ---");
    test_fuzz_against_u64_model();
    test_canaries_and_transaction();
    puts("--- All extended bignum_inverse tests passed ---");
    return 0;
}
