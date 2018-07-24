defmodule UnilinkClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :unilink_client,
      version: "1.0.0-rc0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.html": :test],
      description: description(),
      package: package(),
      source_url: "https://github.com/kelostrada/unilink_client",
      homepage_url: "https://unilink.io"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {UnilinkClient.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 2.2 or ~> 3.0"},
      {:phoenix, "~> 1.3"},
      {:decimal, "~> 1.0"},
      {:mock, "~> 0.3.0", only: :test},
      {:excoveralls, "~> 0.8", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp description() do
    "Elixir client for Unilink Affiliation Service"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/kelostrada/unilink_client"}
    ]
  end
end
