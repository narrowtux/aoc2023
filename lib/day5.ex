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
      list = parse_int_list(line)
      parse_map(rest, [List.to_tuple(list) | acc])
    end

    @spec map(t(), {atom, integer}, atom) :: {atom, integer}
    def map(almanac, {source, number}, destination) do
      mappings = Map.get(almanac.mappings, {source, destination}, [])

      entry =
        Enum.find(mappings, fn {_dest_start, source_start, length} ->
          number in source_start..(source_start + length - 1)
        end)

      case entry do
        nil ->
          {destination, number}

        {dest_start, source_start, _length} ->
          {destination, number - source_start + dest_start}
      end
    end

    @spec map_range(t, {atom, Range.t}, atom) :: [{atom, Range.t}]
    def map_range(almanac, {source, range}, destination) do
      numbers = for x <- range, {_destination, res} = map(almanac, {source, x}, destination), do: res
      # now we compress the numbers back into ranges to save memory
      {last, ranges} =
        Enum.sort(numbers)
        |> Enum.reduce({nil, []}, fn
          x, {nil, acc} -> {x..x, acc}
          x, {from..to, acc} when to + 1 == x -> {from..x, acc}
          x, {outside, acc} -> {x..x, [{destination, outside} | acc]}
        end)

      [{destination, last} | ranges]
    end

    defp to_range(start, length) do
      start .. (start + length - 1)
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
  end

  def part2(variant \\ :day) do
    almanac = almanac(variant)

    Enum.reduce(@path, almanac.seed_ranges, fn dest, values ->
      IO.puts "calculating #{dest}s"
      Enum.flat_map(values, &Almanac.map_range(almanac, &1, dest))
    end)
  end
end
