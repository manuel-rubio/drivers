defmodule DriverLocation.MixProject do
  use Mix.Project

  def project do
    [
      app: :driver_location,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DriverLocation.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_nsq, "~> 1.1"},
      {:redix, "~> 0.9.2"},
      {:cowboy, "~> 2.6"},
      {:poison, "~> 3.1.0"},
      {:hackney, "~> 1.15", only: :test},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test --cover"],
      prod: ["local.hex --force",
             "local.rebar --force",
             "deps.get",
             "compile",
             "run"],
    ]
  end
end
