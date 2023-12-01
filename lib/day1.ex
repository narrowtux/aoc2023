defmodule Day1 do
  def part1 do
    input()
    |> Stream.map(fn code ->
      ints =
        code
        |> String.trim()
        |> String.to_charlist()
        |> Enum.reject(& &1 in ?a..?z)

      [List.first(ints), List.last(ints)]
      |> to_string()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def part2 do
    input()
    |> Stream.map(&parse/1)
    |> Stream.map(&calibrate/1)
    |> Enum.sum()
  end

  def parse(input, acc \\ [])
  def parse("", acc), do: Enum.reverse(acc)
  def parse("one" <> rest, acc), do: parse("ne" <> rest, [1 | acc])
  def parse("two" <> rest, acc), do: parse("wo" <> rest, [2 | acc])
  def parse("three" <> rest, acc), do: parse("hree" <> rest, [3 | acc])
  def parse("four" <> rest, acc), do: parse("our" <> rest, [4 | acc])
  def parse("five" <> rest, acc), do: parse("ive" <> rest, [5 | acc])
  def parse("six" <> rest, acc), do: parse("ix" <> rest, [6 | acc])
  def parse("seven" <> rest, acc), do: parse("even" <> rest, [7 | acc])
  def parse("eight" <> rest, acc), do: parse("ight" <> rest, [8 | acc])
  def parse("nine" <> rest, acc), do: parse("ine" <> rest, [9 | acc])
  def parse("1" <> rest, acc), do: parse(rest, [1 | acc])
  def parse("2" <> rest, acc), do: parse(rest, [2 | acc])
  def parse("3" <> rest, acc), do: parse(rest, [3 | acc])
  def parse("4" <> rest, acc), do: parse(rest, [4 | acc])
  def parse("5" <> rest, acc), do: parse(rest, [5 | acc])
  def parse("6" <> rest, acc), do: parse(rest, [6 | acc])
  def parse("7" <> rest, acc), do: parse(rest, [7 | acc])
  def parse("8" <> rest, acc), do: parse(rest, [8 | acc])
  def parse("9" <> rest, acc), do: parse(rest, [9 | acc])
  def parse(<< _letter :: binary-1, rest :: binary>>, acc), do: parse(rest, acc)

  def calibrate(digits) do
    List.first(digits) * 10 + List.last(digits)
  end

  defp input() do
    Application.app_dir(:aoc2023, "priv/inputs/day1.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
