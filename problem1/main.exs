
defmodule DataParser do
  def parse(body) do
    String.split(body, "\n")
      |> Enum.map(&DataParser.leave_only_nums/1)
      |> Enum.map(&DataParser.first_and_last/1)
      |> Enum.map(fn l -> Enum.join(l, "") end)
      |> Enum.map(&DataParser.to_integer/1)
      |> Enum.sum()
  end

  def first_and_last(l) do
    [List.first(l), List.last(l)]
  end

  def leave_only_nums(str) do
    graphemes = String.graphemes(str)
    r = DataParser.filter_nums(graphemes, [], [])
    r
  end

  def filter_nums([], acc, state) do
    acc
  end

  def filter_nums([head | tail], acc, state) do
    up_state = state ++ [head]
    cond do
      is_num_grapheme(head) -> filter_nums(tail, acc ++ [head], [])
      is_alpha_num(up_state) -> filter_nums(tail, acc ++ [convert_to_num(Enum.join(up_state))], trim_state_to_candidate(up_state))
      is_alpha_num_candidate(up_state) -> filter_nums(tail, acc, up_state)
      true ->
        filter_nums(tail, acc, trim_state_to_candidate(up_state))
    end
  end

  def get_dict do
    %{"one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9"}
  end

  def trim_state_to_candidate([]) do
    []
  end

  def trim_state_to_candidate([head | tail]) do
      case is_alpha_num_candidate(tail) do
        true -> tail
        _ -> trim_state_to_candidate(tail)
      end
  end

  def convert_to_num(alphanum) do
    {:ok, v} = Map.fetch(get_dict(), alphanum)
    v
  end

  def is_alpha_num(state) do
    alphanum = get_dict()
    match = Enum.join(state)
    count = Enum.filter(alphanum, fn {an, _} -> an == match end) |> Enum.count()
    count > 0;
  end

  def is_alpha_num_candidate(state) do
    alphanum = get_dict()
    l = Enum.count(state)

    count = Enum.filter(alphanum, fn {an, nv, } ->
      match = String.graphemes(an) |> Enum.take(l)
      case state do
        ^match ->
          true
        _ -> false
      end
    end) |> Enum.count()

    count > 0
  end

  def filter_nums(graphemes, acc) do
    state = ""
    filter_nums(graphemes, acc, state)
  end

  def is_num_grapheme(g) do
    case Integer.parse(g) do
      {d, ""} ->
        true;
      _ -> false;
    end
  end

  def to_integer(str) do
    case Integer.parse(str) do
      {d, ""} ->
        d;
      _ -> 0
    end
  end

end


main = fn file_path ->
  case File.read(file_path) do
    {:ok, body} ->
      result = DataParser.parse(body);
      IO.inspect(result)
    end
end


#main.("data/sample.txt")
#main.("data/input1.txt")
main.("data/input2.txt")
