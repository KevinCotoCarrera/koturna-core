defmodule Koturna.MixProject do
  use Mix.Project

  def project do
    [
      app: :koturna,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      mod: {Koturna.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_pubsub, "~> 2.2"},
      {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:telemetry, "~> 1.0"},
      {:opentelemetry, "~> 1.2"},
      {:opentelemetry_exporter, "~> 1.6"},
      {:opentelemetry_phoenix, "~> 1.1"},
      {:opentelemetry_ecto, "~> 1.1"},
      {:prom_ex, "~> 1.9"},
      {:logger_json, "~> 6.1"},
      {:oban, "~> 2.17"},
      {:finch, "~> 0.18"},
      {:swoosh, "~> 1.16"},
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.5"},
      {:sweet_xml, "~> 0.7"},
      {:open_api_spex, "~> 3.19"},
      {:cors_plug, "~> 3.0"},
      {:bcrypt_elixir, "~> 0.12.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:req, "~> 0.5"},
      {:corsica, "~> 2.1"},
      {:uuid, "~> 1.1"},
      {:timex, "~> 3.7"},
      {:ex_machina, "~> 2.8", only: :test},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:mox, "~> 1.1", only: :test},
      {:stream_data, "~> 1.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.18", only: :test},
      {:wallaby, "~> 0.30", only: :test, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind koturna", "esbuild koturna"],
      "assets.deploy": [
        "tailwind koturna --minify",
        "esbuild koturna --minify",
        "phx.digest"
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"],
      lint: ["format --check-formatted", "credo --strict"],
      "openapi.spec": ["openapi.spec.json --spec KoturnaWeb.ApiSpec"]
    ]
  end
end
