/**
 * @file test_bignum_inverse_runner.c
 * @brief Linkage smoke test for the public bignum_inverse API.
 * @version 1.0.0
 * @details Verifies that the public header, static library and typed status
 * contract link together and produce a canonical inverse.
 */
#include "bignum_inverse.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

/** @brief Verifies public-header linkage and the canonical 3/11 inverse. */
int main(void)
{
    bignum_t a = { .words = { 3U }, .len = 1U };
    bignum_t m = { .words = { 11U }, .len = 1U };
    bignum_t result;
    memset(&result, 0, sizeof(result));
    assert(bignum_inverse(&result, &a, &m) == BIGNUM_INVERSE_SUCCESS);
    assert(result.len == 1U && result.words[0] == 4U);
    puts("test_bignum_inverse_runner: PASSED");
    return 0;
}
