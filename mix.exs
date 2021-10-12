defmodule MaterializedPath.MixProject do
  use Mix.Project

  @project_url "https://github.com/c4710n/materialized_path"
  @version "0.1.0"

  def project do
    [
      app: :materialized_path,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      source_url: @project_url,
      homepage_url: @project_url,
      description: "Materialized path implementation for Ecto, and general-purpose usage.",
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, ">= 3.0.0"},
      {:ecto_sql, ">= 3.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:postgrex, "~> 0.15.0", only: :test},
      {:myxql, "~> 0.5.1", only: :test},
      {:jason, ">= 0.0.0", only: :test}
    ]
  end

  defp package() do
    [
      name: :ecto_materialized_path,
      files: ["lib/**/*.ex", "mix.exs"],
      maintainers: ["Alex Antonov", "c4710n"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @project_url
      }
    ]
  end

  defp aliases() do
    [
      # Ensures database is reset before tests are run
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
