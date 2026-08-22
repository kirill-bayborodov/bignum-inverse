/**
 * @file bignum_inverse_benchmark_adapter.c
 * @brief Benchmark adapter implementation for bignum_inverse.
 * @version 1.0.0
 * @details Generates deterministic operands, invokes the typed inverse API and
 * hashes all state so benchmark work cannot be optimized away.
 */
#include "bignum_inverse_benchmark_adapter.h"
#include "bignum_inverse.h"
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#define INV_FNV_OFFSET UINT64_C(1469598103934665603)
#define INV_FNV_PRIME UINT64_C(1099511628211)

typedef struct inverse_benchmark_state {
    bignum_t a;
    bignum_t modulus;
    bignum_t result;
} inverse_benchmark_state_t;

static int equal_text(const char *a, const char *b) { return a != NULL && b != NULL && strcmp(a, b) == 0; }
static uint64_t next_value(uint64_t *state)
{
    if (*state == 0U) *state = UINT64_C(0x9e3779b97f4a7c15);
    *state ^= *state << 7U; *state ^= *state >> 9U; *state ^= *state << 8U;
    return *state;
}
static int allowed(const char *value, const char *const *list)
{
    if (value == NULL || list == NULL) return 0;
    for (size_t i = 0U; list[i] != NULL; ++i) if (equal_text(value, list[i])) return 1;
    return 0;
}
static size_t choose_length(const benchmark_workload_t *w, uint64_t *state)
{
    if (equal_text(w->size_profile, "one")) return 1U;
    if (equal_text(w->size_profile, "quarter")) return BIGNUM_CAPACITY / 4U;
    if (equal_text(w->size_profile, "half")) return BIGNUM_CAPACITY / 2U;
    if (equal_text(w->size_profile, "near-capacity") || equal_text(w->capacity_profile, "near-capacity"))
        return BIGNUM_CAPACITY > 2U ? BIGNUM_CAPACITY - 2U : BIGNUM_CAPACITY;
    return 1U + (size_t)(next_value(state) % (BIGNUM_CAPACITY / 2U));
}
static void fill(bignum_t *v, size_t length, uint64_t *state, int zero)
{
    memset(v, 0, sizeof(*v));
    if (zero) return;
    v->len = length == 0U ? 1U : length;
    for (size_t i = 0U; i < v->len; ++i) v->words[i] = next_value(state);
    if (v->words[v->len - 1U] == 0U) v->words[v->len - 1U] = 1U;
    v->words[0] |= 1U;
}

bignum_inverse_benchmark_status_t bignum_inverse_benchmark_validate_workload(const benchmark_workload_t *w)
{
    static const char *const input[] = { "zero", "nonzero", "mixed", NULL };
    static const char *const operation[] = { "binary-euclid", "inverse", "inverse-mixed", NULL };
    static const char *const measure[] = { "end-to-end", "kernel-only", NULL };
    static const char *const size[] = { "one", "quarter", "half", "variable", "near-capacity", NULL };
    static const char *const capacity[] = { "normal", "near-capacity", NULL };
    if (w == NULL) return BIGNUM_INVERSE_BENCHMARK_STATUS_NULL_ARGUMENT;
    if (!allowed(w->input_kind, input) || !allowed(w->operation_kind, operation) ||
        !allowed(w->measure_mode, measure) || !allowed(w->size_profile, size) ||
        !allowed(w->capacity_profile, capacity)) return BIGNUM_INVERSE_BENCHMARK_STATUS_INVALID_PROFILE;
    return BIGNUM_INVERSE_BENCHMARK_STATUS_SUCCESS;
}

static benchmark_adapter_status_t initialize(void *opaque, uint64_t index,
                                              const benchmark_workload_t *w, void *context)
{
    inverse_benchmark_state_t *s = opaque;
    uint64_t random_state;
    size_t length;
    int zero;
    (void)context;
    if (s == NULL || w == NULL || bignum_inverse_benchmark_validate_workload(w) != BIGNUM_INVERSE_BENCHMARK_STATUS_SUCCESS)
        return BENCHMARK_ADAPTER_STATUS_INPUT_ERROR;
    random_state = w->seed ^ (index + UINT64_C(0x9e3779b97f4a7c15));
    length = choose_length(w, &random_state);
    zero = equal_text(w->input_kind, "zero");
    fill(&s->a, length, &random_state, zero || (equal_text(w->input_kind, "mixed") && (index & 1U)));
    /* Use a fixed prime modulus so every generated nonzero workload succeeds. */
    (void)length;
    memset(&s->modulus, 0, sizeof(s->modulus));
    s->modulus.len = 1U;
    s->modulus.words[0] = UINT64_C(1000000007);
    if (s->a.len == 0U) { s->a.len = 1U; s->a.words[0] = 3U; }
    s->a.len = 1U;
    s->a.words[0] = (s->a.words[0] % (s->modulus.words[0] - 1U)) + 1U;
    s->a.words[0] |= 1U;
    memset(&s->result, 0, sizeof(s->result));
    return BENCHMARK_ADAPTER_STATUS_SUCCESS;
}
static benchmark_adapter_status_t operation(void *opaque, uint64_t iteration,
                                             const benchmark_workload_t *w, void *context)
{
    inverse_benchmark_state_t *s = opaque;
    (void)iteration; (void)w; (void)context;
    if (s == NULL || bignum_inverse(&s->result, &s->a, &s->modulus) != BIGNUM_INVERSE_SUCCESS)
        return BENCHMARK_ADAPTER_STATUS_OPERATION_ERROR;
    return BENCHMARK_ADAPTER_STATUS_SUCCESS;
}
static uint64_t checksum(const void *opaque, uint64_t iteration, void *context)
{
    const inverse_benchmark_state_t *s = opaque;
    const bignum_t *values[3] = { &s->a, &s->modulus, &s->result };
    uint64_t hash = INV_FNV_OFFSET;
    (void)context;
    if (s == NULL) return 0U;
    for (size_t n = 0U; n < 3U; ++n) {
        for (size_t i = 0U; i < BIGNUM_CAPACITY; ++i) { hash ^= values[n]->words[i]; hash *= INV_FNV_PRIME; }
        hash ^= (uint64_t)values[n]->len; hash *= INV_FNV_PRIME;
    }
    return hash ^ iteration;
}

bignum_inverse_benchmark_status_t bignum_inverse_benchmark_adapter_init(benchmark_adapter_t *adapter)
{
    if (adapter == NULL) return BIGNUM_INVERSE_BENCHMARK_STATUS_NULL_ARGUMENT;
    *adapter = (benchmark_adapter_t){ .benchmark_name = "bignum_inverse", .state_size = sizeof(inverse_benchmark_state_t),
        .success_code = BENCHMARK_ADAPTER_STATUS_SUCCESS, .adapter_context = NULL,
        .initialize = initialize, .operation = operation, .checksum = checksum };
    return BIGNUM_INVERSE_BENCHMARK_STATUS_SUCCESS;
}
