use Mix.Config

config :driver_location, :http,
  port: 8081

config :driver_location, :redis,
  host: "localhost",
  port: 6379

config :driver_location, :nsq,
  topic: "locations",
  channel: "drivers",
  nsqlookupds: ["localhost:4161"]
