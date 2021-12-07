defmodule BasicMath.Exponential.FastExponential do
  use Bitwise

  @log2 :math.log(2)

  def init() do
    :ets.new(:fast_exponential_16, [:set, :public, :named_table])

    0..15
    |> Enum.map(fn e ->
      0..1023
      |> Enum.map(fn f ->
        <<v::float-16>> = <<0::size(1), e::size(5), f::size(10)>>
        {(e <<< 10) + f, v}
      end)
    end)
    |> List.flatten()
    |> Enum.map(fn {key, value} -> {key, :math.pow(2, value)} end)
    |> Enum.each(fn {key, value} -> :ets.insert(:fast_exponential_16, {key, value}) end)
  end

  def exp16(0), do: 1.0

  def exp16(0.0), do: 1.0

  def exp16(x) do
    x = x / @log2
    xi = Float.floor(x) |> round()
    xf = x - xi
    <<0::size(1), exponent::size(5), fraction::size(10)>> = <<xf::float-16>>

    {xi, fraction} =
      case exponent do
        16 -> {xi + 1, 0}
        _ -> {xi, fraction}
      end

    key = (exponent <<< 10) + fraction
    [{^key, result}] = :ets.lookup(:fast_exponential_16, key)
    <<xi2::float-16>> = <<0::size(1), 15 + xi::size(5), 0::size(10)>>
    xi2 * result
  end
end
