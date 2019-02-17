use Mix.Config

config :zombie_driver,
  # duration in minutes
  duration: 5,
  # distance in meters
  distance: 500

config :zombie_driver, :http,
  port: 8082

config :zombie_driver, :driver_locations,
  host: "127.0.0.1",
  port: 8081
