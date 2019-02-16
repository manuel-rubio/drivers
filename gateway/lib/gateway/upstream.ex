defmodule Gateway.Upstream do
  @callback handle_req(:cowboy_req.req(),
                       data :: term()) :: {code :: Integer.t,
                                           headers :: Map.t,
                                           body :: binary()}
end
