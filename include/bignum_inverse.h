/**
 * @file bignum_inverse.h
 * @brief Public typed API for modular multiplicative inverse of bignum_t values.
 * @version 0.2.2
 * @date 2026-08-22
 * @details Computes x in the canonical range 0 <= x < m such that
 * a*x == 1 (mod m), when gcd(a,m) == 1. The reference and assembly
 * implementations use the extended Euclidean algorithm over normalized unsigned
 * bignum_t records. The API is caller-allocated, allocation-free and publishes
 * the destination only after validation and successful computation.
 *
 * Inputs are borrowed and never modified. The destination is caller-owned and
 * must not overlap either input. Independent calls may execute concurrently.
 */
#ifndef BIGNUM_INVERSE_H
#define BIGNUM_INVERSE_H

#include <bignum.h>
#include <stddef.h>
#include <stdint.h>

#ifndef BIGNUM_CAPACITY
#error "bignum.h must define BIGNUM_CAPACITY"
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Reports the outcome of modular inverse computation.
 * @details A successful status guarantees that result is normalized and in the
 * range [0,m). Every failure status guarantees that result remains unchanged.
 */
typedef enum bignum_inverse_status {
    BIGNUM_INVERSE_SUCCESS = 0, /**< Computation completed; result is the canonical inverse. */
    BIGNUM_INVERSE_ERROR_NULL_ARG = -1, /**< result, a or modulus is NULL; result is unchanged. */
    BIGNUM_INVERSE_ERROR_BAD_LENGTH = -2, /**< An input len exceeds BIGNUM_CAPACITY; retry after normalization. */
    BIGNUM_INVERSE_ERROR_OVERLAP = -3, /**< result overlaps an input; separate caller storage is required. */
    BIGNUM_INVERSE_ERROR_MODULUS_ZERO = -4, /**< modulus is zero; no modular ring is defined and result is unchanged. */
    BIGNUM_INVERSE_ERROR_NO_INVERSE = -5, /**< gcd(a,modulus) is not one or modulus <= 1; result is unchanged. */
    BIGNUM_INVERSE_ERROR_INTERNAL = -6 /**< A validated arithmetic invariant failed; no partial result is published. */
} bignum_inverse_status_t;

/**
 * @brief Computes the modular multiplicative inverse of a modulo modulus.
 * @details The implementation reduces a modulo modulus, runs the extended
 * Euclidean recurrence `(r0,r1) <- (r1,r0-q*r1)` and updates the signed Bezout
 * coefficient for a. If the final gcd is one, the coefficient is normalized
 * into [0, modulus); otherwise NO_INVERSE is returned. Temporary records are
 * private and the caller destination is written only on SUCCESS. Complexity is
 * O(n^2) arithmetic operations with fixed O(n) record storage for the public
 * contract, where n is the number of 64-bit words.
 * @param[out] result Caller-allocated output record. It must be non-NULL and
 * non-overlapping with a and modulus; unchanged on every failure status.
 * @param[in] a Borrowed non-negative input value. It is never modified and may
 * alias modulus because both inputs are copied before arithmetic begins.
 * @param[in] modulus Borrowed positive modulus. Zero returns MODULUS_ZERO; one
 * and non-coprime inputs return NO_INVERSE. It is never modified.
 * @return A named bignum_inverse_status_t value describing publication state.
 * @pre All three pointers are valid, result does not overlap either input, and
 * input lengths are at most BIGNUM_CAPACITY.
 * @post On SUCCESS, result is normalized, satisfies result < modulus and
 * a*result is congruent to one modulo modulus. On failure, result is unchanged.
 * @warning The operation is unsigned; negative a is not representable. The
 * assembly entry point follows System V AMD64 and uses the same record layout.
 * @par Thread safety
 * Safe for concurrent calls when each call uses independent non-overlapping
 * records; the function has no mutable global state.
 */
bignum_inverse_status_t bignum_inverse(
    bignum_t *result,
    const bignum_t *a,
    const bignum_t *modulus);

#ifdef __cplusplus
}
#endif

#endif /* BIGNUM_INVERSE_H */
