defmodule Gateway.Config do
  import Supervisor.Spec
  require Logger

  alias Gateway.Server

  @default_port 8080
  @default_config_yaml "config.yaml"

  def get_port do
    Application.get_env(:gateway, :port, @default_port)
  end

  def filename do
    Application.get_env(:gateway, :config_yaml, @default_config_yaml)
  end

  def get_urls do
    try do
      filename()
      |> YamlElixir.read_all_from_file!()
      |> hd()
      |> Access.get("urls")
    rescue
      _error in ArgumentError ->
        Logger.error "file #{filename()} has errors"
        nil
    catch
      {:yamerl_exception, _} ->
        Logger.error "file #{filename()} not found or wrong format"
        nil
    end
  end

  def get_paths(urls) do
    try do
      for url <- urls, do: process_http(url)
    rescue
      _error in Protocol.UndefinedError ->
        Logger.error "YAML file #{filename()} has errors"
        throw {:error, :config_yaml}
    end
  end

  def get_nsq_children(urls, result \\ [])
  def get_nsq_children([], result), do: result
  def get_nsq_children([%{"nsq" => %{"topic" => topic}}|urls], result) do
    config = %NSQ.Config{nsqds: Application.get_env(:gateway, :nsqds)}
    topic_id = String.to_atom(topic)
    spec = supervisor(NSQ.Producer.Supervisor, [topic, config], id: topic_id)
    get_nsq_children(urls, [spec|result])
  end
  def get_nsq_children([_|urls], result), do: get_nsq_children(urls, result)


  defp process_http(%{"nsq" => %{"topic" => topic},
                     "method" => method,
                     "path" => path}) do
    {String.to_charlist(path), Server, [method, :nsq, String.to_atom(topic)]}
  end
  defp process_http(%{"http" => %{"host" => host},
                     "method" => method,
                     "path" => path}) do
    {String.to_charlist(path), Server, [method, :http, host]}
  end
end
