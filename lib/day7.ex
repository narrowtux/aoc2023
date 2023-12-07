defmodule Day7 do
  @kinds [?A, ?K, ?Q, ?J, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2]
  @kind_values @kinds |> Enum.reverse() |> Enum.with_index() |> Map.new()

  defmodule Hand do
    defstruct [:labels, :bid, :type, :value]

    def parse(input) do
      [labels, bid] = String.split(input, " ")
      labels = String.to_charlist(labels)

      %__MODULE__{
        labels: labels,
        bid: String.to_integer(bid)
      }
    end
  end

  def input(variant \\ :day) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}7.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  def part1(variant \\ :day) do
    variant
    |> input()
    |> Stream.map(&Hand.parse/1)
    |> Stream.map(&value_1/1)
    |> Enum.sort_by(& &1, &sorter/2)
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> rank * hand.bid end)
    |> Enum.sum()
  end

  def part2(variant \\ :day) do
    mapping = %{
      ?J => 0,
      ?A => 12,
      ?K => 11,
      ?Q => 10,
      ?T => 9,
      ?9 => 8,
      ?8 => 7,
      ?7 => 6,
      ?6 => 5,
      ?5 => 4,
      ?4 => 3,
      ?3 => 2,
      ?2 => 1
    }

    variant
    |> input()
    |> Stream.map(&Hand.parse/1)
    |> Enum.map(&value_2/1)
    |> Enum.sort_by(& &1, &sorter(&1, &2, mapping))
    |> IO.inspect()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> rank * hand.bid end)
    |> Enum.sum()
  end

  def value_1(hand) do
    freq =
      hand.labels
      |> Enum.frequencies()
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort()
      |> Enum.reverse()

    {type, value} =
      case freq do
        [5] -> {:five, 7}
        [4, 1] -> {:four, 6}
        [3, 2] -> {:fullhouse, 5}
        [3, 1, 1] -> {:three, 4}
        [2, 2, 1] -> {:twopair, 3}
        [2, 1, 1, 1] -> {:pair, 2}
        [1, 1, 1, 1, 1] -> {:highcard, 1}
      end

    Map.merge(hand, %{value: value, type: type})
  end

  defguard joker_or_same(joker, other) when joker == ?J or joker == other

  def value_2(hand) do
    {type, value} =
      hand.labels
      |> Enum.frequencies()
      |> Enum.sort_by(
        fn
          {?J, _} -> 100
          {_, amount} -> amount
        end,
        :desc
      )
      |> case do
        [{?J, jokers}, {h, a} | rest] -> [{h, a + jokers} | rest]
        list -> list
      end
      |> Enum.flat_map(fn {kind, amount} ->
        for _ <- 1..amount, do: kind
      end)
      |> case do
        [s, s, s, s, s] -> {:five, 7}
        [s, s, s, s, _] -> {:four, 6}
        [s, s, s, o, o] -> {:fullhouse, 5}
        [s, s, s, _, _] -> {:three, 4}
        [s, s, o, o, _] -> {:twopair, 3}
        [s, s, _, _, _] -> {:pair, 2}
        _ -> {:highcard, 1}
      end

    Map.merge(hand, %{value: value, type: type})
  end

  def sorter(lhs, rhs, mapping \\ @kind_values) do
    cond do
      lhs.value > rhs.value ->
        true

      lhs.value < rhs.value ->
        false

      lhs.value == rhs.value ->
        Enum.reduce_while(0..4, nil, fn i, _ ->
          l = Map.get(mapping, Enum.at(lhs.labels, i))
          r = Map.get(mapping, Enum.at(rhs.labels, i))

          cond do
            l == r -> {:cont, true}
            true -> {:halt, r < l}
          end
        end)
    end
  end

  def value_2_from_hand(charlist) do
    %Hand{labels: charlist}
    |> value_2()
  end
end
