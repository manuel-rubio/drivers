defmodule Gateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec
  require Logger

  alias Gateway.{Config, Server}

  def start(_type, _args) do
    # List all child processes to be supervised

    port = Config.get_port()
    urls = Config.get_urls()

    paths = Config.get_paths(urls)
    nsq_children = Config.get_nsq_children(urls)

    children = [
      # Starts a worker by calling: Gateway.Worker.start_link(arg)
      # {Gateway.Worker, arg},
      worker(Server, [port, paths])
    | nsq_children ]

    Logger.info "[app] started"
    Logger.debug "[app] specs: #{inspect children}"

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
