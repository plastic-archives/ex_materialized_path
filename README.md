# MaterializedPath

![badge](https://img.shields.io/hexpm/v/materialized_path.svg)

> An implementation of Materialized Path Pattern, including supports for general-purpose usage and Ecto."

## Installation

Add `materialized_path` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:materialized_path, "~> 0.2.0"}]
end
```

## Docs

Visit [docs hosted by HexDocs](https://hexdocs.pm/materialized_path).

## About Materialized Path Pattern

Materialized Path Pattern stores node position as the path of its ancestors. For example:

```elixir
%Node{ path: [] } # no ancestors => is root
%Node{ path: [1] } # this node is a child of node with id == 1
%Node{ path: [1, 3] } # this node is a child of the node with id == 3, which in its turn is the child of the node with id == 1
```

Search [Materialized Path Pattern](https://www.google.com.hk/search?q=Materialized%20Path%20Pattern) for more information.

## Acknowledgements

This is a fork of [ecto_materialized_path](https://github.com/asiniy/ecto_materialized_path). Thanks, [@asiniy](https://github.com/asiniy).

## License

Apache 2.0
