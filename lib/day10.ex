defmodule Day10 do
  @type pos :: {row :: integer(), col :: integer()}
  @type tile :: ?. | ?S | ?- | ?| | ?7 | ?L | ?F | ?J
  @type pipe_map :: [[tile()]]

  @spec input(atom) :: pipe_map()
  def input(variant) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}10.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
    end)
  end

  def part1(variant \\ :day) do
    map = input(variant)

    start = find_start(map)
    loop = find_loop(map, {-1, -1}, start, [start])

    loop
    |> length()
    |> div(2)
  end

  def part2(variant \\ :day) do
    map = input(variant)

    start = find_start(map)

    map
    |> find_loop({-1, -1}, start, [start])
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.sort_by(&elem(&1, 0))
    |> Stream.map(&tiles_within(&1, map))
    |> Enum.sum()
  end

  def find_loop(map, prev_pos, cur_pos, path) do
    current = get_tile(map, cur_pos)

    cur_pos
    |> nesw()
    |> Enum.reject(&(elem(&1, 1) == prev_pos))
    |> Enum.filter(fn {direction, pos} ->
      neighbor = get_tile(map, pos)

      direction in connections(current) and
        mirror(direction) in connections(neighbor) and
        neighbor != ?S
    end)
    |> Enum.take(1)
    |> case do
      [] -> path
      [{_dir, next}] -> find_loop(map, cur_pos, next, [next | path])
    end
  end

  def tiles_within({row, line}, map) do
    {from, to} =
      Stream.map(line, &elem(&1, 1))
      |> Enum.min_max()

    tiles =
      for col <- from..to do
        if {row, col} in line do
          {col, get_tile(map, {row, col})}
        else
          {col, ?.}
        end
      end

    acc = {_top = 0, _bottom = 0, _tiles = 0}

    Enum.reduce(tiles, acc, fn {col, tile}, {tops, bottoms, tiles} ->
      connections = connections(tile)

      cond do
        tile == ?. and within?(tops, bottoms) ->
          {tops, bottoms, tiles + 1}

        tile == ?| ->
          {tops + 1, bottoms + 1, tiles}

        tile == ?S ->
          # check how many connections go from start to north
          north = get_tile(map, {row - 1, col}) |> connections() |> Enum.count(&(&1 == :south))
          # check how many connections go from start to south
          south = get_tile(map, {row + 1, col}) |> connections() |> Enum.count(&(&1 == :north))
          {tops + north, bottoms + south, tiles}

        :north in connections ->
          {tops + 1, bottoms, tiles}

        :south in connections ->
          {tops, bottoms + 1, tiles}

        true ->
          {tops, bottoms, tiles}
      end
    end)
    |> elem(2)
  end

  def within?(tops, bottoms) do
    rem(tops, 2) == 1 and rem(bottoms, 2) == 1
  end

  def connections(tile) do
    case tile do
      ?S -> [:north, :east, :south, :west]
      ?- -> [:east, :west]
      ?| -> [:north, :south]
      ?7 -> [:west, :south]
      ?F -> [:east, :south]
      ?J -> [:west, :north]
      ?L -> [:east, :north]
      ?. -> []
    end
  end

  def mirror(direction) do
    case direction do
      :north -> :south
      :south -> :north
      :east -> :west
      :west -> :east
    end
  end

  @spec nesw(pos()) :: [{atom, pos}]
  def nesw({row, col}) do
    [north: {-1, 0}, east: {0, 1}, south: {1, 0}, west: {0, -1}]
    |> Enum.map(fn {direction, {rd, cd}} ->
      {direction, {row + rd, col + cd}}
    end)
  end

  def get_tile(map, {row, col}) do
    Enum.at(map, row, [])
    |> Enum.at(col, ?.)
  end

  @spec find_start(pipe_map()) :: pos()
  def find_start(rows) do
    Enum.with_index(rows)
    |> Enum.find_value(fn {row, row_index} ->
      case Enum.find_index(row, &(&1 == ?S)) do
        nil -> nil
        index -> {row_index, index}
      end
    end)
  end
end
