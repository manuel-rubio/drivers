defmodule Gateway.Server do
  require Logger

  alias :cowboy, as: Cowboy
  alias :cowboy_req, as: CowboyReq
  alias :cowboy_router, as: Router

  @behaviour :cowboy_handler

  def start_link(port_number, paths) do
    dispatch = Router.compile [{:_, paths}]
    opts = %{env: %{dispatch: dispatch}}
    port = [{:port, port_number}, :inet]
    {:ok, _} = Cowboy.start_clear(__MODULE__, port, opts)
  end

  @impl true
  def init(req, opts) do
    method = CowboyReq.method(req)
    handle_req(method, req, opts)
  end

  defp get_handler(handler) do
    Module.concat([Gateway.Upstream, String.capitalize("#{handler}")])
  end

  def handle_req(method, req, [method, handler, data] = opts) do
    path = CowboyReq.path(req)
    Logger.info "[http] sending request #{method} #{inspect path} to #{handler} #{data}"
    module = get_handler(handler)
    {code, headers, body} = apply(module, :handle_req, [req, data])
    req = CowboyReq.reply(code, headers, body, req)
    {:ok, req, opts}
  end

  def req_body(req) do
    {:ok, body, _} = CowboyReq.read_body(req)
    body
  end

  def req_method(req), do: CowboyReq.method(req)
  def req_path(req), do: CowboyReq.path(req)
  def req_scheme(req), do: CowboyReq.scheme(req)
  def req_header(req, name, default), do: CowboyReq.header(name, req, default)
  def req_binding(req, name), do: CowboyReq.binding(name, req)
end
