defmodule Day6 do
  @test [{7, 9}, {15, 40}, {30, 200}]
  @day [{49, 298}, {78, 1185}, {79, 1066}, {80, 1181}]

  @test2 {71530, 940200}
  @day2 {49787980, 298118510661181}

  def input(:day), do: @day
  def input(:test), do: @test
  def input2(:day), do: @day2
  def input2(:test), do: @test2

  def part1(variant \\ :day) do
    variant
    |> input()
    |> Enum.map(&ways_to_win/1)
    |> Enum.product()
  end

  def part2(variant \\ :day) do
    variant
    |> input2()
    |> ways_to_win()
  end

  def ways_to_win({time, record}) do
    # margin = max(1, (:math.sqrt(record) |> trunc()) - 10)
    margin = div(time, 20)
    for t <- margin..(time-margin) do
      (time - t) * t - record
    end
    |> Enum.count(& &1 > 0)
  end
end
