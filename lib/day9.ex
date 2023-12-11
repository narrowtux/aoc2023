defmodule Day9 do
  def input(variant \\ :day) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}9.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_int_list/1)
  end

  def part1(variant \\ :day) do
    variant
    |> input()
    |> Stream.map(&predict_next/1)
    |> Enum.sum()
  end
  def part2(variant \\ :day) do
    variant
    |> input()
    |> Stream.map(&Enum.reverse/1)
    |> Stream.map(&predict_next/1)
    |> Enum.sum()
  end

  def parse_int_list(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def predict_next(line) do
    if not all_same?(line) do
      d = derive(line)
      a = predict_next(d)
      List.last(line) + a
    else
      List.first(line)
    end
  end

  def derive(list, acc \\ [])
  def derive([], acc), do: Enum.reverse(acc)
  def derive([_], acc), do: Enum.reverse(acc)
  def derive([a, b | rest], acc) do
    derive([b | rest], [b - a | acc])
  end

  def all_same?(line) do
    line
    |> Enum.frequencies()
    |> Map.keys()
    |> length()
    |> Kernel.==(1)
  end
end
