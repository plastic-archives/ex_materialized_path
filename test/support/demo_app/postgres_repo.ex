defmodule DemoApp.PostgresRepo do
  use Ecto.Repo,
    otp_app: :materialized_path,
    adapter: Ecto.Adapters.Postgres
end
