defmodule Day15 do
  def input(variant) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}15.txt")
    |> File.read!()
    |> String.split(",")
  end

  def hash(string) do
    string
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, hash ->
      rem((hash + char) * 17, 256)
    end)
  end

  def part1(variant \\ :day) do
    input(variant)
    |> Stream.map(&hash/1)
    |> Enum.sum()
  end

  def parse(instruction) do
    cond do
      String.ends_with?(instruction, "-") ->
        label = String.trim_trailing(instruction, "-")
        {:-, hash(label), [label]}

      true ->
        [lens, fl] = String.split(instruction, "=")
        {:=, hash(lens), [lens, String.to_integer(fl)]}
    end
  end

  def part2(variant \\ :day) do
    input(variant)
    |> Stream.map(&parse/1)
    |> Enum.reduce(%{}, fn {op, box, args} = instruction, boxes ->
      case op do
        :- ->
          [lens] = args
          Map.update(boxes, box, [], fn box ->
            case Enum.find_index(box, &elem(&1, 0) == lens) do
              nil ->
                box

              index ->
                List.pop_at(box, index)
                |> elem(1)
            end
          end)

        := ->
          [lens, fc] = args
          Map.update(boxes, box, [{lens, fc}], fn box ->
            case Enum.find_index(box, &elem(&1, 0) == lens) do
              nil -> box ++ [{lens, fc}]
              index ->  List.replace_at(box, index, {lens, fc})
            end
          end)
      end
    end)
    |> Enum.map(fn {box_index, box} ->
      box
      |> Stream.with_index()
      |> Stream.map(fn {{_lens, fc}, lens_index} ->
        (1 + box_index) * (1 + lens_index) * fc
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
