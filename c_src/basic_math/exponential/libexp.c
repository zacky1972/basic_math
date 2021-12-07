#include <erl_nif.h>

static ERL_NIF_TERM init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] =
{
    {"init", 0, init}
};

ERL_NIF_INIT(Elixir.BasicMath.Exponential.ExponentialNif,nif_funcs,NULL,NULL,NULL,NULL)