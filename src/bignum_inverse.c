/**
 * @file bignum_inverse.c
 * @brief C11 reference implementation of modular multiplicative inverse.
 * @version 0.2.1
 * @date 2026-08-22
 * @details Uses Stein's binary extended Euclidean algorithm. Variant B keeps
 * odd-modulus coefficients reduced modulo m and handles even moduli through
 * 2-adic Newton inversion and CRT recombination; the legacy signed pair path
 * remains only as a guarded compatibility fallback.
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
 * @brief Multiplies two records and retains the low fixed-capacity words.
 * @details High words are intentionally discarded for arithmetic modulo 2^k.
 * @param[out] out Private product output.
 * @param[in] left Borrowed normalized factor.
 * @param[in] right Borrowed normalized factor.
 * @return None; output is normalized.
 */
static void inverse_mod2_mul_low(bignum_t *out, const bignum_t *left, const bignum_t *right)
{
    const bignum_t left_copy = *left;
    const bignum_t right_copy = *right;
    memset(out, 0, sizeof(*out));
    for (size_t i = 0U; i < left_copy.len && i < BIGNUM_CAPACITY; ++i) {
        __uint128_t carry = 0U;
        for (size_t j = 0U; j < right_copy.len && i + j < BIGNUM_CAPACITY; ++j) {
            const __uint128_t p = (__uint128_t)left_copy.words[i] * right_copy.words[j]
                                + out->words[i + j] + carry;
            out->words[i + j] = (uint64_t)p;
            carry = p >> 64U;
        }
        for (size_t j = i + right_copy.len; carry != 0U && j < BIGNUM_CAPACITY; ++j) {
            const __uint128_t p = (__uint128_t)out->words[j] + carry;
            out->words[j] = (uint64_t)p;
            carry = p >> 64U;
        }
    }
    out->len = BIGNUM_CAPACITY;
    inverse_normalize(out);
}

/**
 * @brief Masks a private record to its low bit_count bits.
 * @param[in,out] value Private record to truncate.
 * @param[in] bit_count Number of retained low bits, at most capacity bits.
 * @return None; value is normalized after masking.
 */
static void inverse_mod2_mask(bignum_t *value, size_t bit_count)
{
    const size_t words = (bit_count + 63U) / 64U;
    if (words == 0U) { memset(value, 0, sizeof(*value)); return; }
    value->len = words;
    if ((bit_count & 63U) != 0U)
        value->words[words - 1U] &= (UINT64_C(1) << (bit_count & 63U)) - 1U;
    inverse_normalize(value);
}

/**
 * @brief Computes `(left-right) mod 2^bit_count` with fixed-capacity words.
 * @param[out] out Private wrapped difference.
 * @param[in] left Borrowed operand.
 * @param[in] right Borrowed operand.
 * @param[in] bit_count Modulus width in bits.
 * @return None; out is normalized and masked.
 */
static void inverse_mod2_sub(bignum_t *out, const bignum_t *left,
                             const bignum_t *right, size_t bit_count)
{
    memset(out, 0, sizeof(*out));
    uint64_t borrow = 0U;
    const size_t words = (bit_count + 63U) / 64U;
    for (size_t i = 0U; i < words; ++i) {
        const uint64_t lv = i < left->len ? left->words[i] : 0U;
        const uint64_t rv = i < right->len ? right->words[i] : 0U;
        const uint64_t next = borrow ? (lv <= rv) : (lv < rv);
        out->words[i] = lv - rv - borrow;
        borrow = next;
    }
    out->len = words;
    inverse_mod2_mask(out, bit_count);
}

/**
 * @brief Computes an inverse modulo 2^bit_count by Newton doubling.
 * @param[out] output Private inverse residue.
 * @param[in] input Borrowed odd input.
 * @param[in] bit_count Width of the power-of-two modulus.
 * @return Non-zero on success; zero when bit_count is outside capacity.
 */
static int inverse_mod2_newton(bignum_t *output, const bignum_t *input, size_t bit_count)
{
    if (bit_count == 0U || bit_count > BIGNUM_CAPACITY * 64U) return 0;
    bignum_t x, product, two, factor;
    memset(&x, 0, sizeof(x)); x.len = 1U; x.words[0] = 1U;
    size_t precision = 1U;
    while (precision < bit_count) {
        const size_t next = precision * 2U < bit_count ? precision * 2U : bit_count;
        inverse_mod2_mul_low(&product, input, &x);
        inverse_mod2_mask(&product, next);
        memset(&two, 0, sizeof(two)); two.len = 1U; two.words[0] = 2U;
        inverse_mod2_sub(&factor, &two, &product, next);
        inverse_mod2_mul_low(&x, &x, &factor);
        inverse_mod2_mask(&x, next);
        precision = next;
    }
    *output = x;
    return 1;
}

/**
 * @brief Subtracts modular residues without signed coefficient growth.
 * @details Computes `(left - right) mod modulus` while retaining every coefficient
 * in the canonical range. A one-word carry is allowed in the private wide sum.
 * @param[out] out Private normalized residue.
 * @param[in] left Borrowed residue below modulus.
 * @param[in] right Borrowed residue below modulus.
 * @param[in] modulus Borrowed odd positive modulus.
 * @return None; out is fully overwritten.
 */
static void inverse_mod_sub(bignum_t *out, const bignum_t *left,
                            const bignum_t *right, const bignum_t *modulus)
{
    if (inverse_cmp(left, right) >= 0) {
        inverse_sub_raw(out, left, right);
        return;
    }
    bignum_t complement;
    uint64_t wide[BIGNUM_CAPACITY + 1U];
    inverse_sub_raw(&complement, modulus, right);
    const size_t length = inverse_add_wide(wide, &complement, left);
    bignum_t low;
    memset(&low, 0, sizeof(low));
    low.len = length > BIGNUM_CAPACITY ? BIGNUM_CAPACITY : length;
    for (size_t i = 0U; i < low.len; ++i) low.words[i] = wide[i];
    if (length > BIGNUM_CAPACITY || inverse_cmp(&low, modulus) >= 0)
        inverse_sub_raw(out, &low, modulus);
    else
        *out = low;
}

/**
 * @brief Halves a residue coefficient modulo an odd modulus.
 * @details Odd coefficients use `(coefficient + modulus)/2`; the wide temporary
 * prevents overflow when both operands occupy the full public capacity.
 * @param[in,out] coefficient Private residue in `[0,modulus)`.
 * @param[in] modulus Borrowed odd positive modulus.
 * @return None; coefficient remains canonical modulo modulus.
 */
static void inverse_mod_half(bignum_t *coefficient, const bignum_t *modulus)
{
    if (inverse_even(coefficient)) {
        inverse_half(coefficient);
        return;
    }
    uint64_t wide[BIGNUM_CAPACITY + 1U];
    const bignum_t original = *coefficient;
    const size_t length = inverse_add_wide(wide, &original, modulus);
    uint64_t carry = 0U;
    for (size_t i = length; i != 0U; --i) {
        const uint64_t word = wide[i - 1U];
        wide[i - 1U] = (word >> 1U) | (carry << 63U);
        carry = word & 1U;
    }
    memset(coefficient, 0, sizeof(*coefficient));
    coefficient->len = length > BIGNUM_CAPACITY ? BIGNUM_CAPACITY : length;
    for (size_t i = 0U; i < coefficient->len; ++i) coefficient->words[i] = wide[i];
    inverse_normalize(coefficient);
}

/**
 * @brief Shifts a private record right by an arbitrary bit count.
 * @param[in,out] value Private normalized record.
 * @param[in] bits Number of low bits to discard.
 * @return None; value is normalized.
 */
static void inverse_shift_right_bits(bignum_t *value, size_t bits)
{
    const size_t whole = bits / 64U, part = bits & 63U;
    if (whole >= value->len) { memset(value, 0, sizeof(*value)); return; }
    const size_t old_len = value->len;
    for (size_t i = 0U; i + whole < old_len; ++i) {
        uint64_t word = value->words[i + whole] >> part;
        if (part != 0U && i + whole + 1U < old_len)
            word |= value->words[i + whole + 1U] << (64U - part);
        value->words[i] = word;
    }
    value->len = old_len - whole;
    inverse_normalize(value);
}

/**
 * @brief Multiplies bounded records without losing a fitting result.
 * @param[out] out Private product record.
 * @param[in] left Borrowed factor.
 * @param[in] right Borrowed factor.
 * @return Non-zero when the product fits the public capacity.
 */
static int inverse_mul_full(bignum_t *out, const bignum_t *left, const bignum_t *right)
{
    const bignum_t a = *left, b = *right;
    uint64_t accum[BIGNUM_CAPACITY * 2U + 1U];
    memset(accum, 0, sizeof(accum));
    for (size_t i = 0U; i < a.len; ++i) {
        __uint128_t carry = 0U;
        for (size_t j = 0U; j < b.len; ++j) {
            const size_t index = i + j;
            const __uint128_t p = (__uint128_t)a.words[i] * b.words[j]
                                + accum[index] + carry;
            accum[index] = (uint64_t)p;
            carry = p >> 64U;
        }
        size_t index = i + b.len;
        while (carry != 0U && index < sizeof(accum) / sizeof(accum[0])) {
            const __uint128_t p = (__uint128_t)accum[index] + carry;
            accum[index] = (uint64_t)p;
            carry = p >> 64U;
            ++index;
        }
    }
    size_t length = sizeof(accum) / sizeof(accum[0]);
    while (length != 0U && accum[length - 1U] == 0U) --length;
    if (length > BIGNUM_CAPACITY) return 0;
    memset(out, 0, sizeof(*out)); out->len = length;
    for (size_t i = 0U; i < length; ++i) out->words[i] = accum[i];
    return 1;
}

/**
 * @brief Detects whether a normalized modulus is exactly 2^k.
 * @param[in] modulus Borrowed normalized modulus.
 * @param[out] bit_count Receives k when the predicate is true.
 * @return Non-zero only for a positive power of two.
 */
static int inverse_power2_width(const bignum_t *modulus, size_t *bit_count)
{
    size_t nonzero = 0U, index = 0U;
    uint64_t word = 0U;
    for (size_t i = 0U; i < modulus->len; ++i) {
        if (modulus->words[i] != 0U) { ++nonzero; index = i; word = modulus->words[i]; }
    }
    if (nonzero != 1U || (word & (word - 1U)) != 0U) return 0;
    size_t bit = 0U;
    while ((word >>= 1U) != 0U) ++bit;
    *bit_count = index * 64U + bit;
    return *bit_count != 0U;
}

/**
 * @brief Computes an inverse modulo an odd modulus with modular coefficients.
 * @details Binary EEA keeps both residue coefficients bounded by modulus, so
 * near-capacity inputs cannot overflow a signed Bezout magnitude. The caller
 * handles even moduli with the legacy path until the CRT/Hensel component is
 * integrated.
 * @param[out] output Private inverse output.
 * @param[in] input Reduced non-zero residue.
 * @param[in] modulus Borrowed odd modulus greater than one.
 * @return Non-zero when an inverse exists; zero for a non-coprime pair.
 */
static int inverse_mod_odd(bignum_t *output, const bignum_t *input,
                           const bignum_t *modulus)
{
    bignum_t u = *input, v = *modulus, cu, cv;
    memset(&cu, 0, sizeof(cu)); cu.len = 1U; cu.words[0] = 1U;
    memset(&cv, 0, sizeof(cv));
    while (u.len != 0U && v.len != 0U &&
           inverse_cmp(&u, &(bignum_t){ .words = {1U}, .len = 1U }) != 0 &&
           inverse_cmp(&v, &(bignum_t){ .words = {1U}, .len = 1U }) != 0) {
        while (inverse_even(&u)) {
            inverse_half(&u);
            inverse_mod_half(&cu, modulus);
        }
        while (inverse_even(&v)) {
            inverse_half(&v);
            inverse_mod_half(&cv, modulus);
        }
        if (inverse_cmp(&u, &v) >= 0) {
            bignum_t next;
            inverse_sub_raw(&next, &u, &v); u = next;
            inverse_mod_sub(&next, &cu, &cv, modulus); cu = next;
        } else {
            bignum_t next;
            inverse_sub_raw(&next, &v, &u); v = next;
            inverse_mod_sub(&next, &cv, &cu, modulus); cv = next;
        }
    }
    bignum_t one;
    memset(&one, 0, sizeof(one)); one.len = 1U; one.words[0] = 1U;
    if (inverse_cmp(&u, &one) == 0) *output = cu;
    else if (inverse_cmp(&v, &one) == 0) *output = cv;
    else return 0;
    inverse_normalize(output);
    return 1;
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
    /* Variant B avoids signed coefficient growth for odd moduli. */
    size_t power2_bits = 0U;
    if (inverse_power2_width(&m, &power2_bits)) {
        if (inverse_even(&u) || !inverse_mod2_newton(&output, &u, power2_bits))
            return BIGNUM_INVERSE_ERROR_NO_INVERSE;
        *result = output;
        return BIGNUM_INVERSE_SUCCESS;
    }
    if ((m.words[0] & 1U) != 0U) {
        if (!inverse_mod_odd(&output, &u, &m)) return BIGNUM_INVERSE_ERROR_NO_INVERSE;
        *result = output;
        return BIGNUM_INVERSE_SUCCESS;
    }
    /* Variant B CRT path for m = 2^k * q, q odd and q > 1. */
    size_t even_bits = 0U;
    bignum_t q = m;
    while (q.len != 0U && (q.words[0] & 1U) == 0U) {
        inverse_shift_right_bits(&q, 1U);
        ++even_bits;
    }
    if (q.len != 0U && even_bits != 0U) {
        if (inverse_even(&u)) return BIGNUM_INVERSE_ERROR_NO_INVERSE;
        bignum_t a_mod_q, x_q, x_2, q_inv, diff, t, product;
        inverse_reduce(&a_mod_q, &u, &q);
        if (!inverse_mod_odd(&x_q, &a_mod_q, &q)) return BIGNUM_INVERSE_ERROR_NO_INVERSE;
        if (!inverse_mod2_newton(&x_2, &u, even_bits)) return BIGNUM_INVERSE_ERROR_INTERNAL;
        if (!inverse_mod2_newton(&q_inv, &q, even_bits)) return BIGNUM_INVERSE_ERROR_INTERNAL;
        inverse_mod2_sub(&diff, &x_2, &x_q, even_bits);
        inverse_mod2_mul_low(&t, &diff, &q_inv);
        inverse_mod2_mask(&t, even_bits);
        if (!inverse_mul_full(&product, &q, &t)) return BIGNUM_INVERSE_ERROR_INTERNAL;
        {
            uint64_t wide[BIGNUM_CAPACITY + 1U];
            const size_t length = inverse_add_wide(wide, &x_q, &product);
            if (length > BIGNUM_CAPACITY) return BIGNUM_INVERSE_ERROR_INTERNAL;
            memset(&output, 0, sizeof(output)); output.len = length;
            for (size_t i = 0U; i < length; ++i) output.words[i] = wide[i];
            inverse_normalize(&output);
        }
        if (inverse_cmp(&output, &m) >= 0) return BIGNUM_INVERSE_ERROR_INTERNAL;
        *result = output;
        return BIGNUM_INVERSE_SUCCESS;
    }
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
