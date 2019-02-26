defmodule DriverLocation.Store do
  require Logger

  @process_name Redix

  import Supervisor.Spec, only: [worker: 2]

  def spec(redis), do: worker(Redix, [redis])

  defp get_pid do
    Supervisor.which_children(DriverLocation.Supervisor)
    |> List.keyfind(@process_name, 0)
    |> elem(1)
  end

  @spec add(driver :: binary(), info :: Map.t) :: boolean()
  def add(driver, info) do
    Logger.debug "[store] driver #{driver} info: #{inspect info}"
    score = info["updated_at"]
    timestamp = score
                |> DateTime.from_unix!(:seconds)
                |> DateTime.to_iso8601()
    info = info
           |> Map.put("updated_at", timestamp)
           |> Poison.encode!()
    case Redix.command(get_pid(), ["ZADD", driver, score, info]) do
      {:ok, data} ->
        Logger.debug "[store] saved driver #{driver} info: #{inspect data}"
        true
      {:error, error} ->
        Logger.error "[store] cannot store #{driver} error: #{inspect error}"
    end
  end

  def get(driver, minutes) do
    ts_min = timestamp() - (minutes * 60)
    case Redix.command(get_pid(), ["ZREVRANGEBYSCORE", driver, "+inf", ts_min]) do
      {:ok, entries} -> {:ok, Enum.map(entries, &Poison.decode!/1)}
      other -> other
    end
  end

  defp timestamp, do: System.os_time(:seconds)
end
