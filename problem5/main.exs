defmodule DataParser do
  def parse_seeds(seeds_raw) do
    [_, seeds_data ] =  String.split(seeds_raw, ":", trim: true)
    seeds_list = String.split(seeds_data, " ", trim: true)
    Enum.map(seeds_list, fn x -> {r, ""} = Integer.parse(x); r end)
  end

  def parse_map_data(data) do
    nums = String.split(data, " ", trim: true);
    case length(nums) do
      3 ->
        {:ok, dst} = Enum.fetch(nums, 0)
        {:ok, src} = Enum.fetch(nums, 1)
        {:ok, range} = Enum.fetch(nums, 2)

        {src, ""} = Integer.parse(src)
        {dst, ""} = Integer.parse(dst)
        {range, ""} = Integer.parse(range)

        {:ok, %{:src => src, :dst => dst, :range => range}};
      _ ->
        {:error, "wrong input"}
    end
  end

  def parse_maps([head | tail], map, overall_result) do
    case parse_map_data(head) do
      {:ok, data} ->
        parse_maps(tail, map ++ [data], overall_result)

      {:error, e} ->
        parse_maps(tail, [], overall_result ++ [map])
    end
  end

  def parse_maps([], map, overall_result) do
    overall_result ++ [map];
  end

  def parse_maps([head | tail]) do
    parse_maps(tail, [], []);
  end

  def parse(raw) do
    strings = String.split(raw, "\n", trim: true)
    [seeds_raw | maps_raw] = strings;
    data = %{
      :seeds =>  parse_seeds(seeds_raw),
      :maps => parse_maps(maps_raw)
    }

    IO.inspect(data)

    {:ok, data}
  end
end

defmodule Seeding do
  def seed(seed, %{:maps => maps}) do
    pass_through_layers(seed, maps)
  end

  def pass_through_layers(seed, []) do
    {:ok, seed}
  end

  def pass_through_layers(seed, [head_layer | tail_layers]) do
    seed_on_layer = map_on_layer(seed, head_layer)
    pass_through_layers(seed_on_layer, tail_layers)
  end

  def map_on_layer(seed, []) do
    seed
  end

  def map_on_layer(seed, [range | tail]) do
    if seed >= range[:src] && seed < range[:src] + range[:range] do
      offset = seed - range[:src]
      range[:dst] + offset
    else
      map_on_layer(seed, tail)
    end
  end
end

defmodule SeedGenerator do

  def prepare_jobs(range_start, range_end, chunk_size, data)  when range_start < range_end do
    r_end = cond do
      range_start + chunk_size < range_end -> range_start + chunk_size
      true -> range_end
    end

    [{range_start, r_end, data} | prepare_jobs(r_end, range_end, chunk_size, data)]
  end

  def prepare_jobs(range_start, range_end, chunk_size, data) do
    []
  end


  def process_job({seed_start, seed_end, data}) do
    IO.inspect({seed_start, seed_end, (seed_end - seed_start)});
    Enum.reduce(seed_start..seed_end, 0, fn
      seed, acc ->
        {:ok, r} = Seeding.seed(seed, data)
        cond do
          acc == 0 -> r
          r < acc -> r
          true -> acc
        end
      end)
  end

  def generate([], data) do
    []
  end

  def generate([start | [range | tail]], data) do
    IO.inspect({start, range, tail});
    max_chunk = 10000000;
    timeout = :infinity


    result = prepare_jobs(start, start + range, max_chunk, data)
      |> Task.async_stream(fn e -> process_job(e) end, timeout: timeout)
      |> Enum.sort()


    result ++ generate(tail, data);
  end
end

main = fn file_path ->
  case File.read(file_path) do
    {:ok, body} ->
      {:ok, data} = DataParser.parse(body)
      stream = Task.async_stream(data[:seeds], Seeding, :seed, [data])
      result = Enum.sort(stream)
      IO.inspect(result)
    {:error, reason} -> IO.puts(reason)
  end
end

main_part2 = fn file_path ->
  case File.read(file_path) do
    {:ok, body} ->
      {:ok, data} = DataParser.parse(body)
        result = SeedGenerator.generate(data[:seeds], data)
          |> Enum.sort()
        IO.inspect(result)

    {:error, reason} -> IO.puts(reason)
  end
end

main.("data/input1.txt")
main_part2.("data/input2.txt")
