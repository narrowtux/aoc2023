defmodule Day11 do
  def input(variant) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}11.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn line ->
      line
      |> String.to_charlist()
    end)
  end

  def part1(variant \\ :day) do
    variant
    |> input()
    |> sum_distances(1)
  end

  def part2(variant \\ :day) do
    variant
    |> input()
    |> sum_distances(999_999)
  end

  def sum_distances(map, space) do
    width = Enum.at(map, 0) |> length()
    height = length(map)

    free_cols =
      for col <- 0..(width - 1),
          Enum.all?(map, &(Enum.at(&1, col) == ?.)),
          do: col

    free_rows =
      for row <- 0..(height - 1),
          Enum.all?(Enum.at(map, row), &(&1 == ?.)),
          do: row

    galaxies =
      for col <- 0..(width - 1),
          row <- 0..(height - 1),
          Enum.at(map, row, []) |> Enum.at(col, ?.) == ?#,
          do: {row, col}

    for {row_a, col_a} = a <- galaxies,
        {row_b, col_b} = b <- galaxies,
        a != b do
      distance_horizontal =
        abs(col_a - col_b) + Enum.count(free_cols, &(&1 in col_a..col_b)) * space

      distance_vertical =
        abs(row_a - row_b) + Enum.count(free_rows, &(&1 in row_a..row_b)) * space

      distance_horizontal + distance_vertical
    end
    |> Enum.sum()
    |> div(2)
  end
end
