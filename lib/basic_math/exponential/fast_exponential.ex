defmodule BasicMath.Exponential.FastExponential do
  @log2 :math.log(2)

  def init() do
    :ets.new(:fast_exponential_16, [:set, :public, :named_table])

    0..(16 * 1024 - 1)
    |> Enum.map(fn t ->
      <<e::size(5), f::size(10)>> = <<t::size(15)>>
      <<v::float-16>> = <<0::size(1), e::size(5), f::size(10)>>
      {t, v}
    end)
    |> Enum.map(fn {key, value} -> {key, :math.pow(2, value)} end)
    |> Enum.each(fn {key, value} -> :ets.insert(:fast_exponential_16, {key, value}) end)
  end

  def exp16(0), do: 1.0

  def exp16(0.0), do: 1.0

  def exp16(x) do
    x = x / @log2
    xi = Float.floor(x) |> round()
    xf = x - xi
    <<0::size(1), t::size(15)>> = <<xf::float-16>>
    <<exponent::size(5), _fraction::size(10)>> = <<t::size(15)>>

    {xi, t} =
      case exponent do
        16 -> {xi + 1, 0}
        _ -> {xi, t}
      end

    [{^t, result}] = :ets.lookup(:fast_exponential_16, t)
    <<xi2::float-16>> = <<0::size(1), 15 + xi::size(5), 0::size(10)>>
    xi2 * result
  end
end
