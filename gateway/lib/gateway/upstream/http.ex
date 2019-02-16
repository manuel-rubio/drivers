defmodule Gateway.Upstream.Http do
  require Logger
  alias Gateway.Server

  alias :hackney, as: Hackney

  @behaviour Gateway.Upstream

  @default_content_type "application/json"

  @impl true
  def handle_req(req, host) do
    scheme = Server.req_scheme(req)
    method = Server.req_method(req)
             |> String.downcase()
             |> String.to_atom()
    path = Server.req_path(req)
    url = "#{scheme}://#{host}#{path}"
    options = []
    {payload, headers} = if method == :get do
      {"", []}
    else
      {:ok, body, _} = Server.req_body(req)
      content_type = Server.req_header(req, "content-type", @default_content_type)
      {body, [{"content-type", content_type}]}
    end
    case Hackney.request(method, url, headers, payload, options) do
      {:ok, status_code, resp_headers, client_ref} ->
        resp_headers = Enum.into(resp_headers, %{})
        {:ok, resp_body} = Hackney.body(client_ref)
        {status_code, resp_headers, resp_body}
      error ->
        Logger.error "[http] error requesting to #{url} => #{inspect error}"
        {500, %{}, "Error!"}
    end
  end
end
