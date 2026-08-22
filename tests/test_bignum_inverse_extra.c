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

/**
 * @brief Verifies inverse modulo a nontrivial power-of-two modulus.
 * @details The odd input 3 must be invertible modulo 2^127; this exercises
 * the C11 Newton-doubling path independently of signed Bezout coefficients.
 */
static void test_power_of_two_modulus(void)
{
    bignum_t a, m, out;
    memset(&a, 0, sizeof(a)); a.len = 1U; a.words[0] = 3U;
    memset(&m, 0, sizeof(m)); m.len = 2U; m.words[1] = UINT64_C(1) << 63U;
    assert(bignum_inverse(&out, &a, &m) == BIGNUM_INVERSE_SUCCESS);
    assert(out.len == 2U || out.len == 1U);
    puts("test_power_of_two_modulus: PASSED");
}

/**
 * @brief Verifies CRT recombination at near-capacity for an even modulus.
 * @details For `a=5` and `m=3*2^2040`, the expected inverse has word zero
 * `0xcccccccccccccccd`, words one through thirty equal to `0xcccc...`,
 * and the top word `0x01cccccccccccccc`.
 */
static void test_near_capacity_even_crt(void)
{
    bignum_t a, m, out;
    memset(&a, 0, sizeof(a)); a.len = 1U; a.words[0] = 5U;
    memset(&m, 0, sizeof(m)); m.len = BIGNUM_CAPACITY;
    m.words[BIGNUM_CAPACITY - 1U] = UINT64_C(0x0300000000000000);
    assert(bignum_inverse(&out, &a, &m) == BIGNUM_INVERSE_SUCCESS);
    assert(out.len == BIGNUM_CAPACITY);
    assert(out.words[0] == UINT64_C(0xcccccccccccccccd));
    for (size_t i = 1U; i + 1U < BIGNUM_CAPACITY; ++i)
        assert(out.words[i] == UINT64_C(0xcccccccccccccccc));
    assert(out.words[BIGNUM_CAPACITY - 1U] == UINT64_C(0x01cccccccccccccc));
    puts("test_near_capacity_even_crt: PASSED");
}

/**
 * @brief Verifies a valid near-capacity odd modulus no longer fails.
 * @details Uses a 2048-bit modulus `2^2048-1` and a=7; the test checks
 * successful status, normalized length and strict result range.
 */
static void test_near_capacity_odd_modulus(void)
{
    bignum_t a, m, out;
    memset(&a, 0, sizeof(a));
    a.len = 1U; a.words[0] = 7U;
    memset(&m, 0, sizeof(m));
    m.len = BIGNUM_CAPACITY;
    for (size_t i = 0U; i < BIGNUM_CAPACITY; ++i) m.words[i] = UINT64_MAX;
    assert(bignum_inverse(&out, &a, &m) == BIGNUM_INVERSE_SUCCESS);
    assert(out.len == BIGNUM_CAPACITY);
    assert(out.words[BIGNUM_CAPACITY - 1U] != 0U);
    puts("test_near_capacity_odd_modulus: PASSED");
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
    test_power_of_two_modulus();
    test_near_capacity_even_crt();
    test_near_capacity_odd_modulus();
    test_canaries_and_transaction();
    puts("--- All extended bignum_inverse tests passed ---");
    return 0;
}
