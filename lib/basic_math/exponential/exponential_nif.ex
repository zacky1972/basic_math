defmodule BasicMath.Exponential.ExponentialNif do
  require Logger

  @on_load :load_nif

  @doc false
  @spec load_nif() :: :ok
  def load_nif do
    nif_file = '#{Application.app_dir(:basic_math, "priv/libexp")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @spec exp16(number()) :: number()
  def exp16(_x) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
