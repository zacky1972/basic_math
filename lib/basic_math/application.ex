defmodule BasicMath.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    BasicMath.Factorial.FactorialEts.init()
    BasicMath.Exponential.FastExponential.init()

    children = [
      # Starts a worker by calling: BasicMath.Worker.start_link(arg)
      # {BasicMath.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BasicMath.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
