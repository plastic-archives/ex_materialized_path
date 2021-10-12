defmodule MaterializedPath.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/c4710n/ex_materialized_path"

  def project do
    [
      app: :materialized_path,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      source_url: @source_url,
      homepage_url: @source_url,
      description:
        "An implementation of Materialized Path Pattern, including supports for general-purpose usage and Ecto.",
      package: package(),
      deps: deps(),
      aliases: aliases(),
      docs: docs()
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
      {:ex_doc, ">= 0.25.0", only: :dev},
      {:postgrex, "~> 0.15.0", only: :test},
      {:myxql, "~> 0.5.1", only: :test},
      {:jason, ">= 0.0.0", only: :test}
    ]
  end

  defp package() do
    [
      name: :materialized_path,
      files: ["lib/**/*.ex", "mix.exs"],
      maintainers: ["c4710n", "Alex Antonov"],
      licenses: ["Apache 2.0"],
      links: %{GitHub: @source_url}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      publish: ["hex.publish", "tag"],
      tag: &tag_release/1
    ]
  end

  defp tag_release(_) do
    Mix.shell().info("Tagging release as #{@version}")
    System.cmd("git", ["tag", @version])
    System.cmd("git", ["push", "--tags"])
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      extras: ["README.md"]
    ]
  end
end
