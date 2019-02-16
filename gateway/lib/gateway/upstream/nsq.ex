defmodule Gateway.Upstream.Nsq do

  @behaviour Gateway.Upstream

  defp get_nsq_pid_by_topic(topic) do
    Supervisor.which_children(Gateway.Supervisor)
    |> List.keyfind(topic, 0)
    |> elem(1)
  end

  @impl true
  def handle_req(req, topic) do
    body = Gateway.Server.req_body(req)
    topic
    |> get_nsq_pid_by_topic()
    |> NSQ.Producer.pub(body)
    {200, %{}, ""}
  end
end
