defmodule ZombieDriver.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  import Supervisor.Spec

  alias ZombieDriver.Server

  def start(_type, _args) do
    http = Application.get_env(:zombie_driver, :http)
    driver_loc_opts = Application.get_env(:zombie_driver, :driver_locations)

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: ZombieDriver.Worker.start_link(arg)
      # {ZombieDriver.Worker, arg},
      worker(Server, [http, driver_loc_opts]),
    ]

    Logger.info "[app] started"
    Logger.debug "[app] specs: #{inspect children}"

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZombieDriver.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
