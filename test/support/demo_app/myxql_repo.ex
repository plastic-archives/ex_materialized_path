defmodule DemoApp.MyXQLRepo do
  use Ecto.Repo,
    otp_app: :materialized_path,
    adapter: Ecto.Adapters.MyXQL
end
