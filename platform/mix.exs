defmodule Platform.MixProject do
  use Mix.Project

  def project do
    [
      app: :platform,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Platform.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.6.14"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.9.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # Temporary fix for LiveView
      {:phoenix_live_view, "~> 0.18"},
      {:floki, "~> 0.33", only: :test},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.8"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.5"},
      {:ffmpex, "~> 0.10.0"},
      {:temp, "~> 0.4"},
      {:geo_postgis, "~> 3.4"},
      {:paginator, "~> 1.1.0"},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:ex_aws, "~> 2.4"},
      {:ex_aws_s3, "~> 2.3"},
      {:waffle, "~> 1.1"},
      {:sweet_xml, "~> 0.7.3"},
      {:gen_smtp, "~> 1.1"},
      {:hackney, "~> 1.18.0"},
      {:appsignal, "~> 2.3"},
      {:appsignal_phoenix, "~> 2.1"},
      {:earmark, "~> 1.4"},
      {:csv, "~> 2.5"},
      {:oban, "~> 2.13"},
      {:html_sanitize_ex, "~> 1.4"},
      {:eqrcode, "~> 0.1.10"},
      {:nimble_totp, "~> 0.2.0"},
      {:memoize, "~> 1.4"},
      {:libcluster, "~> 3.3"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "cmd --cd assets npm install",
        "esbuild default --minify",
        "cmd --cd assets npx tailwindcss --input=css/app.css --output=../priv/static/assets/app.css --postcss",
        "phx.digest"
      ]
    ]
  end
end
