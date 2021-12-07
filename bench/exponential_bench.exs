input = Enum.map(0..100, fn _ -> :rand.uniform() end)

Benchee.run(
  %{
    ":math.exp(100)" => fn -> Enum.map(input, &:math.exp(&1)) end,
    "FastExponential.exp16(100)" => fn -> Enum.map(input, &BasicMath.Exponential.FastExponential.exp16(&1)) end
  },
  memory_time: 2
)
