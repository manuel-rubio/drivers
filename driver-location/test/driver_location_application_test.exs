defmodule DriverLocationApplicationTest do
  use ExUnit.Case
  doctest DriverLocation.Application

  alias :hackney, as: Hackney
  alias :rand, as: Rand

  def pub(data) do
    config = %NSQ.Config{nsqds: ["127.0.0.1:4150"]}
    {:ok, producer} = NSQ.Producer.Supervisor.start_link("locations", config)
    NSQ.Producer.pub(producer, data)
    #NSQ.Producer.close(producer)
  end

  test "receive a JSON packet via NSQ" do
    ts = System.os_time(:seconds)
    id = Rand.uniform(9999)
    """
    {"latitude": 48.864193, "longitude": 2.350502, "id": #{id}, "updated_at": #{ts}}
    """
    |> String.trim()
    |> pub()

    Process.sleep(1000)

    ts_iso = DateTime.from_unix!(ts)
             |> DateTime.to_iso8601()
    message_stored = """
    [{\"updated_at\":\"#{ts_iso}\",\"longitude\":2.350502,\"latitude\":48.864193}]
    """
    |> String.trim()

    url = "http://localhost:8081/drivers/#{id}/locations?minutes=5"
    headers = []
    payload = ""
    options = []
    {:ok, 200, _headers, client_ref} = Hackney.request(:get, url, headers, payload, options)
    {:ok, resp_body} = Hackney.body(client_ref)
    assert resp_body == message_stored
  end
end
