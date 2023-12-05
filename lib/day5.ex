defmodule Day5 do
  defmodule Almanac do
    @type t :: %__MODULE__{}

    defstruct seeds: [],
              seed_ranges: [],
              mappings: %{}

    def parse(input, almanac \\ %__MODULE__{})
    def parse([], almanac), do: almanac

    def parse(["seeds: " <> seeds, "" | rest], almanac) do
      ints = parse_int_list(seeds)

      seeds = Enum.map(ints, &{:seed, &1})

      seed_ranges =
        ints
        |> Enum.chunk_every(2)
        |> Enum.map(fn [start, length] ->
          {:seed, start..(start + length - 1)}
        end)

      almanac = Map.merge(almanac, %{seeds: seeds, seed_ranges: seed_ranges})
      parse(rest, almanac)
    end

    def parse([map_description | rest], almanac) do
      [_ | from_to] = Regex.run(~r/^([a-z]+)\-to\-([a-z]+) map:$/, map_description)
      [from, to] = Enum.map(from_to, &String.to_atom/1)
      {values, rest} = parse_map(rest)

      values = Enum.sort_by(values, fn {from.._, _} -> from end)

      almanac =
        Map.update!(almanac, :mappings, fn mappings ->
          Map.put(mappings, {from, to}, values)
        end)

      parse(rest, almanac)
    end

    def parse_int_list(int_list) do
      int_list
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end

    def parse_map(lines, acc \\ [])
    def parse_map(["" | rest], acc), do: {Enum.reverse(acc), rest}
    def parse_map([], acc), do: {Enum.reverse(acc), []}

    def parse_map([line | rest], acc) do
      [dest_start, source_start, length] = parse_int_list(line)

      mapping = {
        to_range(source_start, length),
        dest_start - source_start
      }

      parse_map(rest, [mapping | acc])
    end

    @spec map(t(), {atom, integer}, atom) :: {atom, integer}
    def map(almanac, {source, number}, destination) do
      mappings = Map.get(almanac.mappings, {source, destination}, [])

      entry =
        Enum.find(mappings, fn {source, _shift_by} ->
          number in source
        end)

      case entry do
        nil ->
          {destination, number}

        {source_start.._, shift_by} ->
          {destination, number + shift_by}
      end
    end

    @spec map_range(t, {atom, Range.t()}, atom) :: [{atom, Range.t()}]

    def map_range(almanac, {source, range}, destination) do
      mappings = Map.get(almanac.mappings, {source, destination}, [])

      range
      |> reduce_range(mappings)
      |> Enum.map(&{destination, &1})
    end

    def reduce_range(range, mappings, acc \\ [])
    def reduce_range(range, [], acc) do
      [range | acc]
    end
    def reduce_range(range, [next_mapping | rest], acc) do
      {next_range, shift_by} = next_mapping
      cond do
        # range begins after next range, simply skip this range
        range.first > next_range.last ->
          reduce_range(range, rest, acc)

        # range starts and ends before next range
        range.first < next_range.first and Range.disjoint?(range, next_range) ->
          [range | acc]

        # range begins before current range
        range.first < next_range.first ->
          reduce_range(
            next_range.first..range.last,
            [next_mapping | rest],
            [range.first..(next_range.first-1) | acc]
          )

        # range ends after current range
        range.last > next_range.last ->
          range_rest = (next_range.last + 1)..range.last
          range_out = range.first..next_range.last
          range_out = Range.shift(range_out, shift_by)
          reduce_range(range_rest, rest, [range_out | acc])

        # range ends within current range
        range.last <= next_range.last ->
          range_out = Range.shift(range, shift_by)
          [range_out | acc]
      end
    end

    defp to_range(start, length) do
      start..(start + length - 1)
    end
  end

  def almanac(variant \\ :day) do
    Application.app_dir(:aoc2023, "priv/inputs/#{variant}5.txt")
    |> File.stream!()
    |> Enum.map(&String.trim/1)
    |> Almanac.parse()
  end

  @path ~w[soil fertilizer water light temperature humidity location]a

  def part1(variant \\ :day) do
    almanac = almanac(variant)

    Enum.reduce(@path, almanac.seeds, fn dest, values ->
      Enum.map(values, &Almanac.map(almanac, &1, dest))
    end)
    |> Enum.min_by(&elem(&1, 1))
    |> elem(1)
  end

  def part2(variant \\ :day) do
    almanac = almanac(variant)

    Enum.reduce(@path, almanac.seed_ranges, fn dest, values ->
      Enum.flat_map(values, &Almanac.map_range(almanac, &1, dest))
    end)
    |> Enum.min_by(fn {_, first.._} -> first end)
    |> elem(1)
    |> Map.get(:first)
  end
end
