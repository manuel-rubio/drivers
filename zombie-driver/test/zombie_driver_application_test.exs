defmodule ZombieDriverApplicationTest do
  use ExUnit.Case
  doctest ZombieDriver.Application

  alias :hackney, as: Hackney

  ## Server to simulate driver-location service.
  defmodule Server do
    @port 8888
    @endpoint '/drivers/:id/locations'

    alias :cowboy, as: Cowboy
    alias :cowboy_req, as: CowboyReq
    alias :cowboy_router, as: Router

    def start_link do
      paths = [{@endpoint, __MODULE__, []}]
      dispatch = Router.compile [{:_, paths}]
      opts = %{env: %{dispatch: dispatch}}
      port = [{:port, @port}, :inet]
      {:ok, _} = Cowboy.start_clear(__MODULE__, port, opts)
    end

    def init(req, opts) do
      ts = System.os_time(:seconds)
           |> DateTime.from_unix!()
           |> DateTime.to_iso8601()
      headers = %{"content-type" => "application/json"}

      body = case CowboyReq.binding(:id, req, nil) do
        "1000" ->
          """
          []
          """
        "1001" ->
          """
          [{"updated_at":"#{ts}","longitude":2.350502,"latitude":48.864193}]
          """
        "1002" ->
          """
          [{"updated_at":"#{ts}","longitude":2.350502,"latitude":48.864193},
           {"updated_at":"#{ts}","longitude":2.350502,"latitude":50.864193}]
          """
      end
      |> String.trim()
      req = CowboyReq.reply(200, headers, body, req)
      {:ok, req, opts}
    end
  end

  ## request to the zombie-driver service.
  def request(driver, is_zombie) do
    zombie_status = """
    {"zombie":#{is_zombie},"id":#{driver}}
    """
    |> String.trim()

    url = "http://localhost:8082/drivers/#{driver}"
    headers = []
    payload = ""
    options = []
    {:ok, 200, _headers, client_ref} = Hackney.request(:get, url, headers, payload, options)
    {:ok, resp_body} = Hackney.body(client_ref)
    assert resp_body == zombie_status
  end

  test "retrieve zombie driver" do
    {:ok, _} = ZombieDriverApplicationTest.Server.start_link()
    for {driver, is_zombie} <- [{1000, "true"}, {1001, "true"}, {1002, "false"}] do
      request(driver, is_zombie)
    end
  end
end
