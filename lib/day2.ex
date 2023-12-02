defmodule Day2 do
  defp input() do
    Application.app_dir(:aoc2023, "priv/inputs/day2.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Stream.map(&cubes_needed/1)
  end

  def part1() do
    input()
    |> Stream.reject(fn {_game_id, sets} ->
      Enum.any?(sets, fn set ->
        Keyword.get(set, :red, 0) > 12 or
        Keyword.get(set, :green, 0) > 13 or
        Keyword.get(set, :blue, 0) > 14
      end)
    end)
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Stream.map(&game_power/1)
    |> Enum.sum()
  end

  def parse(line, acc \\ {nil, []})
  def parse("Game " <> rest, _acc) do
    [_, id, rest] = Regex.run(~r/^([0-9]+)\:(.*)$/, rest)
    parse(rest, {String.to_integer(id), []})
  end
  def parse(sets, {game_id, []}) do
    sets =
      sets
      |> String.split(";")
      |> Enum.map(fn set ->
        set
        |> String.split(",")
        |> Enum.map(fn draw ->
          [_, amount, color] = Regex.run(~r/^\s*([0-9]+)\s([a-z]+)\s*$/, draw)
          {String.to_integer(amount), String.to_atom(color)}
        end)
      end)

    {game_id, sets}
  end

  def cubes_needed({game_id, sets}) do
    sets =
      Enum.map(sets, fn set ->
        Enum.group_by(set, &elem(&1, 1), &elem(&1, 0))
        |> Enum.map(fn {color, draws} ->
          {color, Enum.sum(draws)}
        end)
      end)

    {game_id, sets}
  end

  def game_power({_game_id, sets}) do
    ~w[red green blue]a
    |> Enum.map(fn color ->
      Enum.reduce(sets, 0, fn set, max ->
        max(Keyword.get(set, color, 0), max)
      end)
    end)
    |> Enum.product()
  end
end
