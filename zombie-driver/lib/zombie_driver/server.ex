defmodule ZombieDriver.Server do
  require Logger

  alias :cowboy, as: Cowboy
  alias :cowboy_req, as: CowboyReq
  alias :cowboy_router, as: Router
  alias ZombieDriver.DriverLocation

  @behaviour :cowboy_handler

  @endpoint '/drivers/:id'

  def start_link(http, extra_opts) do
    paths = [{@endpoint, __MODULE__, extra_opts}]
    dispatch = Router.compile [{:_, paths}]
    opts = %{env: %{dispatch: dispatch}}
    port = [{:port, http[:port]}, :inet]
    {:ok, _} = Cowboy.start_clear(__MODULE__, port, opts)
  end

  @impl true
  def init(req, opts) do
    method = CowboyReq.method(req)
    handle_req(method, req, opts)
  end

  def handle_req("GET", req, opts) do
    path = CowboyReq.path(req)
    Logger.info "[server] request GET #{inspect path}"
    driver = String.to_integer(CowboyReq.binding(:id, req))
    req = case DriverLocation.is_zombie?(driver, opts) do
      value when is_boolean(value) ->
        body = %{"id" => driver,
                 "zombie" => value}
        headers = %{"content-type" => "application/json"}
        CowboyReq.reply(200, headers, Poison.encode!(body), req)
      :error ->
        headers = %{"content-type" => "text/plain"}
        CowboyReq.reply(404, headers, "Not found", req)
    end
    {:ok, req, opts}
  end
  def handle_req(_method, req, opts) do
    headers = %{"content-type" => "text/plain"}
    req = CowboyReq.reply(405, headers, "Method not allowed", req)
    {:ok, req, opts}
  end
end
