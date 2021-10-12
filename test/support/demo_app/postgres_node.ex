defmodule DemoApp.PostgresNode do
  use Ecto.Schema

  use MaterializedPath.Ecto,
    column_name: :path,
    adapter: MaterializedPath.Ecto.Adapters.Postgres

  schema "nodes" do
    field :path, MaterializedPath.Ecto.Path, default: []
  end
end
