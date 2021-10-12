defmodule MaterializedPath.General do
  @moduledoc """
  `MaterializedPath.General` helps to get information from nodes which are organized
  in Materialized Path Pattern.

  It exposes all the standard tree structure relations, such as:
  + parent
  + root
  + ancestors
  + children
  + siblings
  + descendants
  + subtree
  + depth
  + ...

  ## Basic Usage

  Use `use MaterializedPath.General` with following options for a module:
  - `column_name` (default: `:path`) - the name of field which stores tree structure.
  - `key_type` (default: `:atom`) - the type of field key, available values:
    + `:atom`
    + `:string`

  Then, the module will provide the general functions.

  ## An Example

  Define a helper module:

  ```elixir
  defmodule MyApp.TreeHelper do
    use MaterializedPath.General,
      column_name: :path,
      key_type: :string
  end
  ```

  Then, you can call any functions provided by this module.
  """

  defmacro __using__(opts) do
    column_name = Keyword.get(opts, :column_name, :path)
    key_type = Keyword.get(opts, :key_type, :atom)

    column_name = if key_type == :string, do: Atom.to_string(column_name), else: column_name
    id_name = if key_type == :string, do: "id", else: :id

    quote bind_quoted: [
            id_name: id_name,
            column_name: column_name
          ] do
      @type n :: %{optional(any) => any}
      @type nodes :: list(n)
      @type tree :: {n, nodes}

      @doc """
      Return the parent node of a node.
      """
      @spec parent(nodes, n) :: n | nil
      def parent(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        id = parent_id(node)
        get_node(nodes, id)
      end

      @doc """
      Return the parent id of a node.

      The parent id of a root node is `nil`.
      """
      @spec parent_id(n) :: pos_integer | nil
      def parent_id(%{unquote(column_name) => path}) when is_list(path) do
        List.last(path)
      end

      @doc """
      Return the root node of a node.

      The root of a root node is itself.
      """
      @spec root(nodes, n) :: n
      def root(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        id = root_id(node)
        get_node(nodes, id)
      end

      @doc """
      Return root id of a node.

      The root id of a root node is the id of itself.
      """
      @spec root_id(n) :: integer
      def root_id(%{unquote(id_name) => id, unquote(column_name) => []}) when is_integer(id),
        do: id

      def root_id(%{unquote(column_name) => path}) when is_list(path),
        do: List.first(path)

      @doc """
      Return `true` if current node is a root node. Otherwise, return `false`.
      """
      @spec root?(n) :: boolean
      def root?(%{unquote(column_name) => []}),
        do: true

      def root?(%{unquote(column_name) => path}) when is_list(path),
        do: false

      @doc """
      Return all ancestors of a node.
      """
      @spec ancestors(nodes, n) :: nodes
      def ancestors(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        ids = ancestor_ids(node)
        get_nodes(nodes, ids)
      end

      @doc """
      Return a list of ancestor ids of a node.
      """
      @spec ancestor_ids(n) :: [pos_integer]
      def ancestor_ids(%{unquote(column_name) => path}) when is_list(path),
        do: path

      @doc """
      Return a list of nodes whose id is included in `path_ids`.
      """
      @spec path(nodes, n) :: nodes
      def path(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        ids = path_ids(node)
        get_nodes(nodes, ids)
      end

      @doc """
      Return a list of path ids which starts with the root id and ends with the node's own id.
      """
      @spec path_ids(n) :: [pos_integer]
      def path_ids(%{unquote(id_name) => id, unquote(column_name) => path} = node)
          when is_list(path),
          do: ancestor_ids(node) ++ [id]

      @doc """
      Return all children of a node.
      """
      @spec children(nodes, n) :: nodes
      def children(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        path = path_ids(node)

        Enum.filter(nodes, fn node ->
          Map.get(node, unquote(column_name)) == path
        end)
      end

      @doc """
      Return all siblings of a node.
      """
      @spec siblings(nodes, n) :: nodes
      def siblings(nodes, %{unquote(column_name) => path}) when is_list(path) do
        Enum.filter(nodes, fn node ->
          Map.get(node, unquote(column_name)) == path
        end)
      end

      @doc """
      Return all descendants of a node.
      """
      @spec descendants(nodes, n) :: nodes
      def descendants(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        path = path_ids(node)

        Enum.filter(nodes, fn node ->
          node
          |> Map.get(unquote(column_name))
          |> List.starts_with?(path)
        end)
      end

      @doc """
      Return current node and all its descendants.
      """
      @spec subtree(nodes, n) :: nodes
      def subtree(nodes, %{unquote(column_name) => path} = node) when is_list(path) do
        descendants = descendants(nodes, node)
        [node | descendants]
      end

      @doc """
      Return the depth of a given node in the tree.

      It returns `0` for root node.
      """
      @spec depth(n) :: non_neg_integer
      def depth(%{unquote(column_name) => path}) when is_list(path),
        do: length(path)

      @doc """
      Build a tree from a given list of nodes.

      It will raise an exception if it can't build the tree with given list of nodes.

      The tree consists of following structure:

      ```elixir
      {node, a_list_of_children}
      ```

      ## An example

      ```elixir
      node_1 = %{ id: 1 }
      node_3 = %{ id: 3, path: [1] }
      node_8 = %{ id: 8, path: [1, 3] }
      node_9 = %{ id: 9, path: [1, 3, 8] }
      node_4 = %{ id: 4, path: [1] }
      node_5 = %{ id: 5, path: [1] }
      node_2 = %{ id: 2 }
      node_6 = %{ id: 6, path: [2] }
      node_7 = %{ id: 7, path: [2, 6] }

      list = [node_1, node_2, node_3, node_4, node_5, node_6, node_7, node_8, node_9]
      TreeHelper.arrange(list)
      # =>
      # [
      #   {node_1, [
      #     {node_3, [
      #       {node_8, [
      #         {node_9, []}
      #       ]}
      #     ]},
      #     {node_4, []},
      #     {node_5, []}
      #   ]},
      #   {node_2, [
      #     {node_6, [
      #       {node_7, []}
      #     ]}
      #   ]}
      # ]
      ```
      """
      @spec arrange(nodes) :: tree
      def(arrange([]), do: [])

      def arrange(nodes) when is_list(nodes) do
        nodes_depth_map = nodes_by_depth_map(nodes, %{})

        initial_depth_level = nodes_depth_map |> Map.keys() |> Enum.min()
        initial_list = Map.get(nodes_depth_map, initial_depth_level)
        initial_nodes_depth_map = Map.delete(nodes_depth_map, initial_depth_level)

        {tree, tree_nodes_count} =
          Enum.reduce(
            initial_list,
            {[], length(initial_list)},
            &extract_to_resulting_structure(
              &1,
              &2,
              initial_nodes_depth_map,
              initial_depth_level
            )
          )

        check_nodes_arrangement_correctness(tree, tree_nodes_count, nodes)

        tree
      end

      defp nodes_by_depth_map([], processed_map), do: processed_map

      defp nodes_by_depth_map([node | tail], before_node_processed_map) do
        path = Map.get(node, unquote(column_name))
        node_depth = depth(node)

        node_at_depth = Map.get(before_node_processed_map, node_depth, []) ++ [node]
        after_node_processed_map = Map.put(before_node_processed_map, node_depth, node_at_depth)

        nodes_by_depth_map(tail, after_node_processed_map)
      end

      defp extract_to_resulting_structure(
             node,
             {list, total_count},
             nodes_depth_map,
             depth_level
           ) do
        next_depth_level = depth_level + 1

        {node_children, node_children_count} =
          nodes_depth_map
          |> Map.get(next_depth_level, [])
          |> Enum.filter(fn possible_children ->
            possible_children
            |> Map.get(unquote(column_name))
            |> List.last() == get_node_id(node)
          end)
          |> Enum.reduce(
            {[], total_count},
            &extract_to_resulting_structure(
              &1,
              &2,
              nodes_depth_map,
              next_depth_level
            )
          )

        {list ++ [{node, node_children}], length(node_children) + node_children_count}
      end

      defp check_nodes_arrangement_correctness(tree, tree_nodes_count, nodes) do
        nodes_count = length(nodes)

        if tree_nodes_count != nodes_count do
          nodes_ids = Enum.map(nodes, &get_node_id/1)

          tree_node_ids =
            tree
            |> Enum.map(fn element -> get_node_ids_from_tree(element) end)
            |> List.flatten()

          missing_node_ids = nodes_ids -- tree_node_ids

          raise ArgumentError,
                "nodes with ids [#{Enum.join(missing_node_ids, ", ")}] can't be arranged"
        end
      end

      defp get_node_ids_from_tree({node, []}), do: [get_node_id(node)]

      defp get_node_ids_from_tree({node, list}) do
        [get_node_id(node), Enum.map(list, &get_node_ids_from_tree(&1))]
      end

      defp get_node(nodes, id) do
        Enum.find(nodes, fn node -> get_node_id(node) == id end)
      end

      defp get_nodes(nodes, ids) do
        Enum.filter(nodes, fn node -> get_node_id(node) in ids end)
      end

      defp get_node_id(node) do
        Map.get(node, unquote(id_name))
      end
    end
  end
end
