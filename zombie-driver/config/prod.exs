use Mix.Config

config :zombie_driver,
  # duration in minutes
  duration: 5,
  # distance in meters
  distance: 500

config :zombie_driver, :http,
  port: 80

config :zombie_driver, :driver_locations,
  host: "driver-location",
  port: 80
