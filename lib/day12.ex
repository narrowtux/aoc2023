defmodule Day12 do
  def input(variant) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}11.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line ->
      [map, record] = String.split(line, " ")
      record = record |> String.split(",") |> Enum.map(&String.to_integer/1)
      {String.to_charlist(map), record}
    end)
  end

  def part1(variant \\ :day) do
    variant
    |> input()
    |> Stream.map(&variants/1)
    |> Enum.sum()
  end

  def variants(line)
  def variants({'', rest}), do: rest == []
  def variants()
end
