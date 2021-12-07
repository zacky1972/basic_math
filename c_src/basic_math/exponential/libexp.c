#include <erl_nif.h>

int load(ErlNifEnv* caller_env, void** priv_data, ERL_NIF_TERM load_info)
{
    return 0;
}

int upgrade(ErlNifEnv* caller_env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
    return 0;
}

void unload(ErlNifEnv* caller_env, void* priv_data)
{
}

static ERL_NIF_TERM init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] =
{
    {"init", 0, init}
};

ERL_NIF_INIT(Elixir.BasicMath.Exponential.ExponentialNif, nif_funcs, load, NULL, upgrade, unload)