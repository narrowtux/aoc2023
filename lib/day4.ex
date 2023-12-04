defmodule Day4 do
  defp input() do
    Application.app_dir(:aoc2023, "priv/inputs/day4.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  defmodule Card do
    defstruct [:id, :winning, :our, :matches, :copies]

    def parse(input) do
      [_, id, winning, our] = Regex.run(~r/^Card\s+([0-9]+):\s([0-9\s]+)\|\s([0-9\s]+)$/, input)

      trans_list = fn input ->
        input
        |> String.replace(~r/\s+/, " ")
        |> String.trim()
        |> String.split(" ")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
      end

      card = %__MODULE__{
        id: String.to_integer(id),
        winning: trans_list.(winning),
        our: trans_list.(our),
        copies: 1
      }
      Map.put(card, :matches, winning_numbers(card))
    end

    def score(card) do
      matches = winning_numbers(card)

      :math.pow(2, matches - 1)
      |> trunc()
    end

    def winning_numbers(card) do
      Enum.count(card.winning, &(&1 in card.our))
    end
  end

  def part1 do
    input()
    |> Stream.map(&Card.parse/1)
    |> Stream.map(&Card.score/1)
    |> Enum.sum()
  end

  def part2 do
    cards = Enum.map(input(), &Card.parse/1)

    blub(cards)
    |> Enum.map(& &1.copies)
    |> Enum.sum()
  end

  def blub(cards, acc \\ [])
  def blub([], acc), do: acc
  def blub([current | rest], acc) do
    {cards_to_clone, rest} = Enum.split(rest, current.matches)
    cloned_cards = Enum.map(cards_to_clone, fn card ->
      Map.update!(card, :copies, & &1 + current.copies)
    end)
    blub(cloned_cards ++ rest, [current | acc])
  end
end
