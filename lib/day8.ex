defmodule Day8 do
  def input(variant \\ :day) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}8.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  defmodule CamelMap do
    defstruct [:path, :graph]

    def parse(stream) do
      lines = Enum.into(stream, [])
      [path, "" | graph] = lines

      path =
        path
        |> String.to_charlist()
        |> Enum.map(fn
          ?R -> :right
          ?L -> :left
        end)

      graph =
        Enum.reduce(graph, %{}, fn line, graph ->
          [_, from, left, right] =
            Regex.run(~r/([0-9A-Z]{3}) = \(([0-9A-Z]{3}), ([0-9A-Z]{3})\)/, line)

          Map.put(graph, from, {left, right})
        end)

      %__MODULE__{path: path, graph: graph}
    end
  end

  def part1(variant \\ :day) do
    variant
    |> input()
    |> CamelMap.parse()
    |> get_steps("AAA", "ZZZ")
  end

  def part2(variant \\ :day) do
    map =
      input(variant)
      |> CamelMap.parse()

    map.graph
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(&get_steps(map, &1, "Z"))
    |> Enum.reduce(&BasicMath.lcm/2)
  end

  def get_steps(map, from, to) do
    map.path
    |> Stream.cycle()
    |> Enum.reduce_while({from, 0}, fn instruction, {node, steps} ->
      next = choose_next(node, map, instruction)
      cond do
        String.ends_with?(next, to) -> {:halt, steps + 1}
        true -> {:cont, {next, steps + 1}}
      end
    end)
  end

  def choose_next(node, map, instruction) do
    {left, right} = Map.get(map.graph, node)

    case instruction do
      :left -> left
      :right -> right
    end
  end
end
