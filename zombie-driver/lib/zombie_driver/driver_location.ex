defmodule ZombieDriver.DriverLocation do
  require Logger

  alias :hackney, as: Hackney

  defp endpoint(driver, minutes), do: "/drivers/#{driver}/locations?minutes=#{minutes}"

  defp minutes, do: Application.get_env(:zombie_driver, :duration)
  defp distance, do: Application.get_env(:zombie_driver, :distance)

  def get(driver, minutes, opts) do
    url = "http://#{opts[:host]}:#{opts[:port]}#{endpoint(driver, minutes)}"
    headers = []
    payload = ""
    options = []
    case Hackney.request(:get, url, headers, payload, options) do
      {:ok, 200, _headers, client_ref} ->
        {:ok, resp_body} = Hackney.body(client_ref)
        {:ok, resp_body
              |> Poison.decode!()
              |> Enum.map(&([&1["latitude"], &1["longitude"]]))}
      error ->
        Logger.error "[http] error requesting to #{url} => #{inspect error}"
        :error
    end
  end

  def is_zombie?(driver, opts) do
    case get(driver, minutes(), opts) do
      {:ok, [_]} -> false
      {:ok, []} -> false
      {:ok, locations} -> calc_distance(locations) <= distance()
      :error -> :error
    end
  end

  def calc_distance(locations, meters \\ 0)
  def calc_distance([], meters), do: meters
  def calc_distance([_], meters), do: meters
  def calc_distance([p1, p2|others], meters) do
    meters = Geocalc.distance_between(p1, p2) + meters
    calc_distance([p2|others], meters)
  end
end
