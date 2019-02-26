use Mix.Config

config :driver_location, :http,
  port: 80

config :driver_location, :redis,
  host: "redis",
  port: 6379

config :driver_location, :nsq,
  topic: "locations",
  channel: "drivers",
  nsqlookupds: ["nsqlookup:4161"]
