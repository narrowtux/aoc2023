defmodule Day3 do
  defp input() do
    Application.app_dir(:aoc2023, "priv/inputs/day3.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  def part1 do
    lines = Enum.into(input(), [])

    numbers =
      Enum.with_index(lines)
      |> Enum.flat_map(fn {line, index} ->
        extract_numbers(line, index)
      end)

    for {number, from, to, line} <- numbers, reduce: 0 do
      acc ->
        current_line = Enum.at(lines, line)
        line_before = Enum.at(lines, line - 1)
        line_after = Enum.at(lines, line + 1)
        if contains_part?(line_before, from - 1, to + 1) or
          contains_part?(line_after, from - 1, to + 1) or
          contains_part?(current_line, from - 1, from) or
          contains_part?(current_line, to, to + 1) do
          # IO.puts("#{number} is a label")
          acc + number
        else
          # IO.puts("#{number} is not a label")
          acc
        end
    end
  end

  def part2 do
    lines =
      input()
      |> Enum.into([])
      |> Enum.with_index()

    numbers =
      Enum.flat_map(lines, fn {line, index} ->
        extract_numbers(line, index)
      end)

    gears =
      Enum.flat_map(lines, fn {line, index} ->
        find_gears(line, index)
      end)

    gears
    |> Enum.flat_map(fn gear ->
      case Enum.filter(numbers, &adjacent_to_gear?(&1, gear)) do
        [{a, _, _, _}, {b, _, _, _}] -> [a * b]
        _ -> []
      end
    end)
    |> Enum.sum()
  end

  @digits ~w[0 1 2 3 4 5 6 7 8 9]

  def extract_numbers(line, y, x \\ 0, acc \\ [])
  def extract_numbers("", _, _, acc), do: acc
  def extract_numbers(<<symbol::binary-1, rest::binary>>, y, x, acc) do
    case symbol do
      number when number in @digits ->
        {number, rest} = take_number(number <> rest)
        until = x + String.length(number)
        token = {String.to_integer(number), x, until, y}
        extract_numbers(rest, y, until, [token | acc])
      _ ->
        extract_numbers(rest, y, x + 1, acc)
    end
  end

  def find_gears(line, y, x \\ 0, acc \\ [])
  def find_gears("", _, _, acc), do: acc
  def find_gears("*" <> rest, y, x, acc) do
    token = {x, y}
    find_gears(rest, y, x + 1, [token | acc])
  end
  def find_gears(<< _ :: binary-1, rest :: binary>>, y, x, acc) do
    find_gears(rest, y, x + 1, acc)
  end

  def take_number(string, acc \\ "")
  def take_number("", acc), do: {acc, ""}
  def take_number(<<symbol::binary-1, rest::binary>>, acc) when symbol not in @digits,
    do: {acc, symbol <> rest}
  def take_number(<<digit::binary-1, rest::binary>>, acc) do
    take_number(rest, acc <> digit)
  end

  def contains_part?(nil, _, _), do: false
  def contains_part?(line, from, to) do
    from = max(0, from)
    line
    |> String.slice(from, to - from)
    |> String.match?(~r/[^\.0-9]/)
  end

  def adjacent_to_gear?({_, from, to, ny}, {gx, gy}) do
    (ny in (gy-1)..(gy+1)) and
    (gx in (from - 1)..to)
  end
end
