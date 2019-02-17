defmodule ZombieDriver.MixProject do
  use Mix.Project

  def project do
    [
      app: :zombie_driver,
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
      mod: {ZombieDriver.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.6"},
      {:hackney, "~> 1.15"},
      {:poison, "~> 3.1.0"},
      {:geocalc, "~> 0.5"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["test --cover"],
    ]
  end
end
