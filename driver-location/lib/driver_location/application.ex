defmodule DriverLocation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  import Supervisor.Spec

  alias DriverLocation.Server

  def start(_type, _args) do
    nsq = Application.get_env(:driver_location, :nsq)
    redis = Application.get_env(:driver_location, :redis)
    http = Application.get_env(:driver_location, :http)

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: DriverLocation.Worker.start_link(arg)
      # {DriverLocation.Worker, arg},
      DriverLocation.Store.spec(redis),
      DriverLocation.Nsq.spec(nsq),
      worker(Server, [http]),
    ]

    Logger.info "[app] started"
    Logger.debug "[app] specs: #{inspect children}"

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DriverLocation.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
