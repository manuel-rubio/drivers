defmodule DriverLocation.Nsq do
  require Logger

  import Supervisor.Spec, only: [supervisor: 3]

  alias DriverLocation.Store

  def spec(nsq) do
    nsqlookupds = nsq[:nsqlookupds]
    topic = nsq[:topic]
    channel = nsq[:channel]

    config = %NSQ.Config{nsqlookupds: nsqlookupds,
                         message_handler: &handler_msg/2}
    topic_id = String.to_atom(topic)

    supervisor(NSQ.Consumer.Supervisor, [topic, channel, config], name: topic_id)
  end

  @spec handler_msg(body :: binary(), msg :: %NSQ.Message{}) :: :ok | :error
  def handler_msg(body, msg) do
    Logger.debug "[app] message received:\n\tbody => #{inspect body}\n\tmsg => #{inspect msg}"
    info = Poison.decode!(body)
    if Store.add(info["id"], info) do
      :ok
    else
      :error
    end
  end
end
