input = Enum.map(0..100, fn _ -> :rand.uniform() end)

Benchee.run(
  %{
    ":math.exp x100" => fn -> Enum.map(input, &:math.exp(&1)) end,
    "ExponentialNif.exp16 x100" => fn ->
      Enum.map(input, &BasicMath.Exponential.ExponentialNif.exp16(&1))
    end
  },
  memory_time: 2
)
