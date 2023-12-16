defmodule Day16 do
  @directions ~w[north east south west]a
  @horizontal ~w[east west]a
  @vertical ~w[north south]a

  def input(variant) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}16.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn line ->
      String.to_charlist(line)
    end)
  end

  @type input :: [charlist()]
  @type direction :: :north | :east | :south | :west
  @type pos :: {integer, integer, direction}

  def part1(variant) do
    map = input(variant)
    count_energized(map, {0, 0, :east})
  end

  def part2(variant) do
    map = input(variant)
    width = (Enum.at(map, 0) |> length()) - 1
    height = length(map) - 1
    starts =
      # left
      for(row <- 0..height, do: {row, 0, :east}) ++
      # top
      for(col <- 0..width, do: {0, col, :south}) ++
      # right
      for(row <- 0..height, do: {row, width, :west}) ++
      # bottom
      for(col <- 0..width, do: {height, col, :north})

    Stream.map(starts, &count_energized(map, &1))
    |> Enum.max()
  end

  def count_energized(map, start_position) do
    visited = raytrace(map, start_position)

    visited
    |> Stream.map(&Tuple.delete_at(&1, 2))
    |> Enum.uniq()
    |> Enum.count()
  end

  @spec raytrace(input, pos, MapSet.t()) :: MapSet.t()
  def raytrace(map, pos, visited \\ MapSet.new()) do
    if is_nil(tile_at(map, pos)) do
      visited
    else
      visited = MapSet.put(visited, pos)

      new_positions =
        follow(map, pos)
        |> Enum.reject(&(&1 in visited))

      Enum.reduce(new_positions, visited, &raytrace(map, &1, &2))
    end
  end

  def print_map(map, visited) do
    for row <- 0..(length(map) - 1),
        line = Enum.at(map, row),
        (row > 0 && IO.puts("") == :ok) or true,
        col <- 0..(length(line) - 1),
        tile = Enum.at(line, col) do
      dirs =
        Enum.filter(visited, fn {r, c, _} ->
          row == r and col == c
        end)
        |> Enum.map(&elem(&1, 2))

      cond do
        dirs == [] -> [tile]
        tile != ?. -> [tile]
        dirs == [:north] -> "^"
        dirs == [:east] -> ">"
        dirs == [:south] -> "v"
        dirs == [:west] -> "<"
        true -> to_string(length(dirs))
      end
      |> IO.write()
    end

    IO.puts("")
    IO.puts("")
  end

  @spec follow(input, pos) :: [pos]
  def follow(map, pos) do
    {row, col, direction} = pos
    tile = tile_at(map, pos)

    tile
    |> next_directions(direction)
    |> Enum.map(&advance({row, col, &1}))
  end

  def next_directions(tile, direction) do
    cond do
      is_nil(tile) -> []
      tile == ?. -> [direction]
      tile == ?- and direction in ~w[east west]a -> [direction]
      tile == ?| and direction in ~w[north south]a -> [direction]
      tile == ?\\ and direction in @horizontal -> [cw(direction)]
      tile == ?\\ and direction in @vertical -> [ccw(direction)]
      tile == ?/ and direction in @horizontal -> [ccw(direction)]
      tile == ?/ and direction in @vertical -> [cw(direction)]
      tile in ~c"-|" -> [ccw(direction), cw(direction)]
    end
  end

  def advance(pos) do
    {row, col, direction} = pos

    case direction do
      :north -> {row - 1, col, direction}
      :east -> {row, col + 1, direction}
      :south -> {row + 1, col, direction}
      :west -> {row, col - 1, direction}
    end
  end

  def tile_at(_, {row, col, _}) when row < 0 or col < 0 do
    nil
  end

  def tile_at(map, {row, col, _}) do
    Enum.at(map, row, [])
    |> Enum.at(col, nil)
  end

  def cw(direction) do
    turn(direction, +1)
  end

  def ccw(direction) do
    turn(direction, -1)
  end

  defp turn(direction, steps) do
    index = Enum.find_index(@directions, &(&1 == direction))
    Enum.at(@directions, rem(index + steps, 4))
  end
end
