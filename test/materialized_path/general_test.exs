defmodule MaterializedPath.GeneralTest do
  use ExUnit.Case, async: true

  defmodule TreeHelper do
    use MaterializedPath.General, column_name: :path
  end

  setup do
    nodes = [
      %{id: 1, path: []},
      %{id: 2, path: [1]},
      %{id: 3, path: [1, 2]},
      %{id: 4, path: [1, 2]},
      %{id: 5, path: [1, 2, 4]},
      %{id: 7, path: [1, 2]},
      %{id: 8, path: [1, 2, 7]},
      %{id: 9, path: []},
      %{id: 10, path: [9]}
    ]

    {:ok, nodes: nodes}
  end

  defp get_node(nodes, id) do
    Enum.find(nodes, fn node -> node.id == id end)
  end

  defp get_nodes(nodes, ids) do
    Enum.filter(nodes, fn node -> node.id in ids end)
  end

  describe "parent/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert nil == TreeHelper.parent(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      parent = get_node(nodes, 2)
      child = get_node(nodes, 3)
      assert parent == TreeHelper.parent(nodes, child)
    end
  end

  describe "parent_id/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert nil == TreeHelper.parent_id(root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 2)
      assert 1 == TreeHelper.parent_id(child)
    end
  end

  describe "root/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert root == TreeHelper.root(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      child = get_node(nodes, 3)
      assert root == TreeHelper.root(nodes, child)
    end
  end

  describe "root_id/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert 1 == TreeHelper.root_id(root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert 1 == TreeHelper.root_id(child)
    end
  end

  describe "root?" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert true == TreeHelper.root?(root)
    end

    test "for a child node", %{nodes: nodes} do
      child_1 = get_node(nodes, 2)
      child_2 = get_node(nodes, 3)
      assert false == TreeHelper.root?(child_1)
      assert false == TreeHelper.root?(child_2)
    end
  end

  describe "ancestors/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert [] == TreeHelper.ancestors(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert get_nodes(nodes, [1, 2]) == TreeHelper.ancestors(nodes, child)
    end
  end

  describe "ancestor_ids/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert [] == TreeHelper.ancestor_ids(root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert [1, 2] == TreeHelper.ancestor_ids(child)
    end
  end

  describe "path/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert [root] == TreeHelper.path(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert get_nodes(nodes, [1, 2]) ++ [child] == TreeHelper.path(nodes, child)
    end
  end

  describe "path_ids/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert [1] == TreeHelper.path_ids(root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert [1, 2, 3] == TreeHelper.path_ids(child)
    end
  end

  describe "children/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert get_nodes(nodes, [2]) == TreeHelper.children(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 2)
      assert get_nodes(nodes, [3, 4, 7]) == TreeHelper.children(nodes, child)
    end
  end

  describe "siblings/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert get_nodes(nodes, [1, 9]) == TreeHelper.siblings(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert get_nodes(nodes, [3, 4, 7]) == TreeHelper.siblings(nodes, child)
    end
  end

  describe "descendants/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert get_nodes(nodes, [2, 3, 4, 5, 7, 8]) == TreeHelper.descendants(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 2)
      assert get_nodes(nodes, [3, 4, 5, 7, 8]) == TreeHelper.descendants(nodes, child)
    end
  end

  describe "subtree/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert get_nodes(nodes, [1, 2, 3, 4, 5, 7, 8]) == TreeHelper.subtree(nodes, root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 2)
      assert get_nodes(nodes, [2, 3, 4, 5, 7, 8]) == TreeHelper.subtree(nodes, child)
    end
  end

  describe "depth/1" do
    test "for a root node", %{nodes: nodes} do
      root = get_node(nodes, 1)
      assert 0 == TreeHelper.depth(root)

      root = get_node(nodes, 9)
      assert 0 == TreeHelper.depth(root)
    end

    test "for a child node", %{nodes: nodes} do
      child = get_node(nodes, 3)
      assert 2 == TreeHelper.depth(child)

      child = get_node(nodes, 2)
      assert 1 == TreeHelper.depth(child)

      child = get_node(nodes, 8)
      assert 3 == TreeHelper.depth(child)
    end
  end

  describe "arrange/1" do
    test "arranges the whole tree", %{nodes: nodes} do
      tree = TreeHelper.arrange(nodes)

      assert tree == [
               {
                 get_node(nodes, 1),
                 [
                   {
                     get_node(nodes, 2),
                     [
                       {get_node(nodes, 3), []},
                       {get_node(nodes, 4),
                        [
                          {get_node(nodes, 5), []}
                        ]},
                       {get_node(nodes, 7),
                        [
                          {get_node(nodes, 8), []}
                        ]}
                     ]
                   }
                 ]
               },
               {
                 get_node(nodes, 9),
                 [
                   {
                     get_node(nodes, 10),
                     []
                   }
                 ]
               }
             ]
    end

    test "arranges the subtree as well", %{nodes: nodes} do
      nodes = Enum.filter(nodes, fn node -> node.id in [2, 3, 4, 5, 7, 8] end)
      tree = TreeHelper.arrange(nodes)

      assert tree == [
               {
                 get_node(nodes, 2),
                 [
                   {get_node(nodes, 3), []},
                   {get_node(nodes, 4),
                    [
                      {get_node(nodes, 5), []}
                    ]},
                   {get_node(nodes, 7),
                    [
                      {get_node(nodes, 8), []}
                    ]}
                 ]
               }
             ]
    end

    test "return empty list if there is no child" do
      assert TreeHelper.arrange([]) == []
    end

    test "raises an exception when node can't arranged", %{nodes: nodes} do
      nodes = Enum.reject(nodes, fn node -> node.id == 4 end)

      assert_raise ArgumentError, "nodes with ids [5] can't be arranged", fn ->
        TreeHelper.arrange(nodes)
      end
    end
  end

  # describe "column_name" do
  #   defmodule AnotherTreeHelper do
  #     use Ecto.Schema

  #     use MaterializedPath.Ecto,
  #       column_name: :way,
  #       adapter: MaterializedPath.Ecto.Adapters.Postgres

  #     schema "another_comments" do
  #       field :way, MaterializedPath.Ecto.Path
  #     end
  #   end

  #   test "can be customized manually" do
  #     node = %AnotherTreeHelper{way: [15, 41, 22]}
  #     assert AnotherTreeHelper.ancestor_ids(node) == [15, 41, 22]
  #   end
  # end
end
