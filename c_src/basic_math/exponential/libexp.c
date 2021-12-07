#include <erl_nif.h>
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#define BINARY16_EXPONENT_1 16
#define BINARY16_FRACTION_BITS 10

union f16 {
    _Float16 f;
    uint16_t u;
};

static float *fast_exponential_16;
static double log_2;

static int load(ErlNifEnv* caller_env, void** priv_data, ERL_NIF_TERM load_info)
{
    fast_exponential_16 = (float *)enif_alloc(sizeof(float) * (BINARY16_EXPONENT_1 * (1 << BINARY16_FRACTION_BITS) + 1));
    if(__builtin_expect(fast_exponential_16 == NULL, false)) {
        return 1;
    }
    union f16 t;
    for(uint_fast8_t e = 0; e < BINARY16_EXPONENT_1; e++) {
        for(uint_fast16_t f = 0; f < (1 << BINARY16_FRACTION_BITS); f++) {
            t.u = ((e << BINARY16_FRACTION_BITS) | f);
            fast_exponential_16[t.u] = powf(2.0, t.f);
        }
    }
    t.u = BINARY16_EXPONENT_1 * (1 << BINARY16_FRACTION_BITS);
    fast_exponential_16[t.u] = powf(2.0, t.f);
    log_2 = log(2);
    *priv_data = fast_exponential_16;
    return 0;
}

static int upgrade(ErlNifEnv* caller_env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
    *priv_data = *old_priv_data;
    fast_exponential_16 = *priv_data;
    log_2 = log(2);
    return 0;
}

static void unload(ErlNifEnv* caller_env, void* priv_data)
{
    enif_free(fast_exponential_16);
    enif_free(priv_data);
}

static ERL_NIF_TERM exp16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 1, false)) {
        return enif_make_badarg(env);
    }
    double x;
    if(__builtin_expect(!enif_get_double(env, argv[0], &x), false)) {
        ErlNifSInt64 n;
        if(__builtin_expect(!enif_get_int64(env, argv[0], &n), false)) {
            return enif_raise_exception(env, enif_make_atom(env, "ArithmeticError"));
        }
        x = (double)n;
    }
    x /= log_2;
    ErlNifSInt64 xi = (ErlNifSInt64)floor(x);
    union f16 xf;
    xf.f = (_Float16)(x - xi);
    union f16 xi2;
    xi2.u = ((BINARY16_EXPONENT_1 - 1 + xi) << BINARY16_FRACTION_BITS);
    return enif_make_double(env, (double)xi2.f * fast_exponential_16[xf.u]);
}

static ErlNifFunc nif_funcs[] =
{
    {"exp16", 1, exp16}
};

ERL_NIF_INIT(Elixir.BasicMath.Exponential.ExponentialNif, nif_funcs, load, NULL, upgrade, unload)