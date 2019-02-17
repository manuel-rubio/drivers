defmodule DriverLocation.Server do
  require Logger

  alias :cowboy, as: Cowboy
  alias :cowboy_req, as: CowboyReq
  alias :cowboy_router, as: Router
  alias DriverLocation.Store

  @behaviour :cowboy_handler

  @endpoint '/drivers/:id/locations'

  def start_link(http) do
    paths = [{@endpoint, __MODULE__, []}]
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

  defp filter(%{"latitude" => lat, "longitude" => long, "updated_at" => ts}) do
    %{"latitude" => lat,
      "longitude" => long,
      "updated_at" => ts}
  end

  def handle_req("GET" = method, req, opts) do
    path = CowboyReq.path(req)
    Logger.info "[server] request #{method} #{inspect path}"
    driver = CowboyReq.binding(:id, req)
    qs = CowboyReq.parse_qs(req)
    req = with {"minutes", min} <- List.keyfind(qs, "minutes", 0),
               {minutes, ""} <- Integer.parse(min),
               {:ok, [_|_] = entries} <- Store.get(driver, minutes) do
      body = entries
             |> Enum.map(&filter/1)
             |> Enum.reverse()
             |> Poison.encode!()
      headers = %{"content-type" => "application/json"}
      CowboyReq.reply(200, headers, body, req)
    else
      error ->
        headers = %{"content-type" => "application/json"}
        Logger.error "[server] wrong: #{inspect error}"
        CowboyReq.reply(404, headers, "Not found", req)
    end
    {:ok, req, opts}
  end
  def handle_req(method, req, opts) do
    headers = %{"content-type" => "text/plain"}
    req = CowboyReq.reply(405, headers, "Method not allowed", req)
    {:ok, req, opts}
  end
end
