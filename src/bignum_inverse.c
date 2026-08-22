/**
 * @file bignum_inverse.c
 * @brief C11 reference implementation of modular multiplicative inverse.
 * @version 1.0.0
 * @date 2026-08-22
 * @details Uses Stein's binary extended Euclidean algorithm. Residues are
 * unsigned bignum_t values and Bezout coefficients are fixed-size signed
 * magnitudes, preserving the exact identity for both odd and even moduli.
 */
#include "bignum_inverse.h"
#include <stdint.h>
#include <string.h>

/** @brief Fixed-size signed magnitude used by the private binary EEA state. */
typedef struct inverse_signed {
    bignum_t magnitude; /**< Unsigned fixed-capacity coefficient magnitude. */
    int negative; /**< Non-zero when the coefficient is represented as negative. */
} inverse_signed_t;

/**
 * @brief Detects overlap between two complete bignum records.
 * @details Uses byte ranges before dereferencing either record.
 * @param[in] left Borrowed record address; may be NULL only for internal misuse.
 * @param[in] right Borrowed record address; may be NULL only for internal misuse.
 * @return Non-zero when the complete records overlap; zero otherwise.
 */
static int inverse_overlap(const bignum_t *left, const bignum_t *right)
{
    const uintptr_t a = (uintptr_t)left;
    const uintptr_t b = (uintptr_t)right;
    const uintptr_t size = (uintptr_t)sizeof(bignum_t);
    return a < b ? (b - a) < size : (a - b) < size;
}

/**
 * @brief Normalizes a private unsigned record and clears unused words.
 * @details Trims zero most-significant words and preserves the zero invariant.
 * @param[in,out] value Private caller-owned temporary record; never NULL here.
 * @return None; the record is normalized in place.
 */
static void inverse_normalize(bignum_t *value)
{
    size_t length = value->len;
    if (length > BIGNUM_CAPACITY) length = BIGNUM_CAPACITY;
    while (length != 0U && value->words[length - 1U] == 0U) --length;
    for (size_t i = length; i < BIGNUM_CAPACITY; ++i) value->words[i] = 0U;
    value->len = length;
}

/**
 * @brief Compares two normalized unsigned records.
 * @param[in] left Borrowed normalized record.
 * @param[in] right Borrowed normalized record.
 * @return Positive, zero or negative according to unsigned numeric order.
 */
static int inverse_cmp(const bignum_t *left, const bignum_t *right)
{
    if (left->len != right->len) return left->len > right->len ? 1 : -1;
    for (size_t i = left->len; i != 0U; --i) {
        if (left->words[i - 1U] != right->words[i - 1U])
            return left->words[i - 1U] > right->words[i - 1U] ? 1 : -1;
    }
    return 0;
}

/**
 * @brief Subtracts one bounded unsigned record from another.
 * @details The precondition left >= right prevents unsigned underflow.
 * @param[out] out Private output record, fully overwritten.
 * @param[in] left Borrowed normalized minuend.
 * @param[in] right Borrowed normalized subtrahend not greater than left.
 * @return None; output is normalized by the caller when required.
 */
static void inverse_sub_raw(bignum_t *out, const bignum_t *left, const bignum_t *right)
{
    uint64_t borrow = 0U;
    memset(out, 0, sizeof(*out));
    out->len = left->len;
    for (size_t i = 0U; i < left->len; ++i) {
        const uint64_t lv = left->words[i];
        const uint64_t rv = i < right->len ? right->words[i] : 0U;
        const uint64_t next = borrow ? (lv <= rv) : (lv < rv);
        out->words[i] = lv - rv - borrow;
        borrow = next;
    }
    inverse_normalize(out);
}

/**
 * @brief Adds two unsigned records into a bounded wide buffer.
 * @param[out] out Caller-provided buffer with BIGNUM_CAPACITY+1 words.
 * @param[in] left Borrowed normalized addend.
 * @param[in] right Borrowed normalized addend.
 * @return Number of significant words in out, including a carry word.
 */
static size_t inverse_add_wide(uint64_t *out, const bignum_t *left, const bignum_t *right)
{
    uint64_t carry = 0U;
    const size_t length = left->len > right->len ? left->len : right->len;
    memset(out, 0, (BIGNUM_CAPACITY + 1U) * sizeof(*out));
    for (size_t i = 0U; i < length; ++i) {
        const uint64_t lv = i < left->len ? left->words[i] : 0U;
        const uint64_t rv = i < right->len ? right->words[i] : 0U;
        const uint64_t sum = lv + rv;
        const uint64_t c1 = sum < lv;
        const uint64_t next = sum + carry;
        const uint64_t c2 = next < sum;
        out[i] = next;
        carry = c1 | c2;
    }
    out[length] = carry;
    return length + (carry != 0U);
}

/**
 * @brief Divides a normalized unsigned record by two in place.
 * @details The caller establishes that the operation is exact for its residue state.
 * @param[in,out] value Private normalized record to modify.
 * @return None; value remains normalized.
 */
static void inverse_half(bignum_t *value)
{
    uint64_t carry = 0U;
    for (size_t i = value->len; i != 0U; --i) {
        const uint64_t word = value->words[i - 1U];
        value->words[i - 1U] = (word >> 1U) | (carry << 63U);
        carry = word & 1U;
    }
    inverse_normalize(value);
}

/**
 * @brief Tests the parity of a normalized unsigned record.
 * @param[in] value Borrowed normalized record.
 * @return Non-zero for zero or even values; zero for odd values.
 */
static int inverse_even(const bignum_t *value)
{
    return value->len == 0U || (value->words[0] & 1U) == 0U;
}

/**
 * @brief Canonicalizes a signed-magnitude coefficient.
 * @param[in,out] value Private signed coefficient; zero is made non-negative.
 * @return None; magnitude and sign are normalized together.
 */
static void inverse_signed_normalize(inverse_signed_t *value)
{
    inverse_normalize(&value->magnitude);
    if (value->magnitude.len == 0U) value->negative = 0;
}

/**
 * @brief Computes signed left minus right in fixed capacity.
 * @details The caller guarantees the mathematical result fits the magnitude buffer.
 * @param[out] out Private signed output coefficient.
 * @param[in] left Borrowed signed coefficient.
 * @param[in] right Borrowed signed coefficient.
 * @return None; out is overwritten and normalized.
 */
static void inverse_signed_sub(inverse_signed_t *out, const inverse_signed_t *left,
                               const inverse_signed_t *right)
{
    inverse_signed_t a = *left;
    inverse_signed_t b = *right;
    if (a.negative != b.negative) {
        uint64_t wide[BIGNUM_CAPACITY + 1U];
        const size_t length = inverse_add_wide(wide, &a.magnitude, &b.magnitude);
        memset(out, 0, sizeof(*out));
        if (length > BIGNUM_CAPACITY) return;
        out->magnitude.len = length;
        for (size_t i = 0U; i < length; ++i) out->magnitude.words[i] = wide[i];
        out->negative = a.negative;
        inverse_signed_normalize(out);
        return;
    }
    const int cmp = inverse_cmp(&a.magnitude, &b.magnitude);
    memset(out, 0, sizeof(*out));
    if (cmp >= 0) {
        inverse_sub_raw(&out->magnitude, &a.magnitude, &b.magnitude);
        out->negative = a.negative;
    } else {
        inverse_sub_raw(&out->magnitude, &b.magnitude, &a.magnitude);
        out->negative = !a.negative;
    }
    inverse_signed_normalize(out);
}

/**
 * @brief Adds two signed-magnitude coefficients.
 * @details Reuses signed subtraction so sign and magnitude rules stay centralized.
 * @param[out] out Private signed output coefficient.
 * @param[in] left Borrowed signed coefficient.
 * @param[in] right Borrowed signed coefficient.
 * @return None; out is overwritten and normalized.
 */
static void inverse_signed_add(inverse_signed_t *out, const inverse_signed_t *left,
                               const inverse_signed_t *right)
{
    inverse_signed_t neg = *right;
    neg.negative = !neg.negative;
    inverse_signed_sub(out, left, &neg);
}

/**
 * @brief Halves a Bezout coefficient pair without changing its residue identity.
 * @details When x is odd, adds modulus to x and subtracts a from y before halving.
 * @param[in,out] x Signed coefficient of a; modified in place.
 * @param[in,out] y Signed coefficient of modulus; modified in place.
 * @param[in] a Reduced input value used by the congruence transformation.
 * @param[in] m Modulus used by the congruence transformation.
 * @return Non-zero when both coefficients were halved successfully; zero on capacity failure.
 */
static int inverse_pair_half(inverse_signed_t *x, inverse_signed_t *y,
                             const bignum_t *a, const bignum_t *m)
{
    if (inverse_even(&x->magnitude) && inverse_even(&y->magnitude)) {
        inverse_half(&x->magnitude); inverse_half(&y->magnitude);
        inverse_signed_normalize(x); inverse_signed_normalize(y);
        return 1;
    }
    inverse_signed_t sm, sa, nx, ny;
    memset(&sm, 0, sizeof(sm)); sm.magnitude = *m;
    memset(&sa, 0, sizeof(sa)); sa.magnitude = *a;
    inverse_signed_add(&nx, x, &sm);
    inverse_signed_sub(&ny, y, &sa);
    if (!inverse_even(&nx.magnitude) || !inverse_even(&ny.magnitude)) return 0;
    inverse_half(&nx.magnitude); inverse_half(&ny.magnitude);
    inverse_signed_normalize(&nx); inverse_signed_normalize(&ny);
    *x = nx; *y = ny;
    return 1;
}

/**
 * @brief Reduces an unsigned record modulo a positive modulus.
 * @details Scans input bits most-significant first and keeps remainder below modulus.
 * @param[out] out Private normalized remainder record.
 * @param[in] input Borrowed normalized input record.
 * @param[in] modulus Borrowed non-zero normalized modulus.
 * @return None; out is fully overwritten.
 */
static void inverse_reduce(bignum_t *out, const bignum_t *input, const bignum_t *modulus)
{
    bignum_t remainder;
    memset(&remainder, 0, sizeof(remainder));
    for (size_t word = input->len; word != 0U; --word) {
        for (unsigned bit = 64U; bit != 0U; --bit) {
            uint64_t carry = (input->words[word - 1U] >> (bit - 1U)) & 1U;
            for (size_t i = 0U; i < BIGNUM_CAPACITY; ++i) {
                const uint64_t old = remainder.words[i];
                remainder.words[i] = (old << 1U) | carry;
                carry = old >> 63U;
            }
            remainder.len = BIGNUM_CAPACITY;
            inverse_normalize(&remainder);
            if (carry != 0U || inverse_cmp(&remainder, modulus) >= 0) {
                bignum_t difference;
                inverse_sub_raw(&difference, &remainder, modulus);
                remainder = difference;
            }
        }
    }
    *out = remainder;
}

/**
 * @brief Computes the modular inverse using signed binary extended Euclid.
 * @details The public parameter ownership and status contract are declared in
 * the header; this definition implements the same ABI without heap allocation.
 * @return Named bignum_inverse_status_t result code.
 */
bignum_inverse_status_t bignum_inverse(bignum_t *result, const bignum_t *a,
                                       const bignum_t *modulus)
{
    bignum_t u, v, m, one, output;
    inverse_signed_t coefficient_u, coefficient_v, coefficient_uy, coefficient_vy;
    if (result == NULL || a == NULL || modulus == NULL) return BIGNUM_INVERSE_ERROR_NULL_ARG;
    if (inverse_overlap(result, a) || inverse_overlap(result, modulus)) return BIGNUM_INVERSE_ERROR_OVERLAP;
    if (a->len > BIGNUM_CAPACITY || modulus->len > BIGNUM_CAPACITY) return BIGNUM_INVERSE_ERROR_BAD_LENGTH;
    u = *a; v = *modulus; inverse_normalize(&u); inverse_normalize(&v); m = v;
    if (v.len == 0U) return BIGNUM_INVERSE_ERROR_MODULUS_ZERO;
    memset(&one, 0, sizeof(one)); one.len = 1U; one.words[0] = 1U;
    if (inverse_cmp(&v, &one) <= 0) return BIGNUM_INVERSE_ERROR_NO_INVERSE;
    inverse_reduce(&u, &u, &m);
    if (u.len == 0U) return BIGNUM_INVERSE_ERROR_NO_INVERSE;
    bignum_t base = u;
    memset(&coefficient_u, 0, sizeof(coefficient_u));
    coefficient_u.magnitude.len = 1U; coefficient_u.magnitude.words[0] = 1U;
    memset(&coefficient_v, 0, sizeof(coefficient_v));
    memset(&coefficient_uy, 0, sizeof(coefficient_uy));
    memset(&coefficient_vy, 0, sizeof(coefficient_vy));
    coefficient_vy.magnitude.len = 1U; coefficient_vy.magnitude.words[0] = 1U;
    while (u.len != 0U && v.len != 0U && inverse_cmp(&u, &one) != 0 && inverse_cmp(&v, &one) != 0) {
        while (inverse_even(&u)) {
            inverse_half(&u);
            if (!inverse_pair_half(&coefficient_u, &coefficient_uy, &base, &m)) goto no_inverse;
        }
        while (inverse_even(&v)) {
            inverse_half(&v);
            if (!inverse_pair_half(&coefficient_v, &coefficient_vy, &base, &m)) goto no_inverse;
        }
        if (inverse_cmp(&u, &v) >= 0) {
            bignum_t difference;
            inverse_sub_raw(&difference, &u, &v); u = difference;
            inverse_signed_t next;
            inverse_signed_sub(&next, &coefficient_u, &coefficient_v);
            coefficient_u = next;
            inverse_signed_sub(&next, &coefficient_uy, &coefficient_vy);
            coefficient_uy = next;
        } else {
            bignum_t difference;
            inverse_sub_raw(&difference, &v, &u); v = difference;
            inverse_signed_t next;
            inverse_signed_sub(&next, &coefficient_v, &coefficient_u);
            coefficient_v = next;
            inverse_signed_sub(&next, &coefficient_vy, &coefficient_uy);
            coefficient_vy = next;
        }
    }
    inverse_signed_t *winner = NULL;
    if (inverse_cmp(&u, &one) == 0) winner = &coefficient_u;
    else if (inverse_cmp(&v, &one) == 0) winner = &coefficient_v;
    else goto no_inverse;
    bignum_t reduced_coefficient;
    inverse_reduce(&reduced_coefficient, &winner->magnitude, &m);
    if (winner->negative && reduced_coefficient.len != 0U)
        inverse_sub_raw(&output, &m, &reduced_coefficient);
    else output = reduced_coefficient;
    inverse_normalize(&output);
    if (inverse_cmp(&output, &m) >= 0) return BIGNUM_INVERSE_ERROR_INTERNAL;
    *result = output;
    return BIGNUM_INVERSE_SUCCESS;
no_inverse:
    return BIGNUM_INVERSE_ERROR_NO_INVERSE;
}
