defmodule BasicMath.Exponential.ExponentialNifTest do
  use ExUnit.Case
  doctest BasicMath.Exponential.ExponentialNif

  @float_16_epsilon :math.pow(2, 1 - 12)

  test "compare to :math.exp" do
    ExUnit.configuration()[:seed]

    1..20
    |> Enum.map(fn _ -> :rand.uniform() end)
    |> Enum.map(
      &assert :math.exp(&1) - BasicMath.Exponential.ExponentialNif.exp16(&1) < @float_16_epsilon
    )
  end
end
