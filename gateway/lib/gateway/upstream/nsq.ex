defmodule Gateway.Upstream.Nsq do

  @behaviour Gateway.Upstream

  defp get_nsq_pid_by_topic(topic) do
    Supervisor.which_children(Gateway.Supervisor)
    |> List.keyfind(topic, 0)
    |> elem(1)
  end

  @impl true
  def handle_req(req, topic) do
    id = Gateway.Server.req_binding(req, :id)
    body = req
           |> Gateway.Server.req_body()
           |> Poison.decode!()
           |> Map.put("updated_at", timestamp())
           |> Map.put("id", id)
           |> Poison.encode!()
    topic
    |> get_nsq_pid_by_topic()
    |> NSQ.Producer.pub(body)
    {200, %{}, ""}
  end

  defp timestamp, do: System.os_time(:seconds)
end
