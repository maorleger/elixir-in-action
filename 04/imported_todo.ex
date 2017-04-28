defmodule MultiDict do
  def new, do: HashDict.new

  def add(dict, k, v) do

    HashDict.update(dict, k, [v], fn(vs) -> [v|vs] end)

  end

  def get(dict, k) do
    HashDict.get(dict, k, [])
  end
end

defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new, do: %TodoList{}

  def new(entries \\ []) do
    entries
    |> IO.inspect
    |>
    Enum.reduce(  %TodoList{}, &add_entry(&2, &1))
  end 

  def add_entry(%TodoList{entries: entries, auto_id: auto_id} = todo_list, entry) do
    # entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def add_entry(todolist, k, v) do
    MultiDict.add(todolist, k, v)
  end

  def entries(todolist, k) do
    MultiDict.get(todolist, k)
  end
end

defimpl String.Chars, for: TodoList do
  def to_string(%TodoList{entries: entries, auto_id: auto_id}) do 
    String.Chars.to_string(entries)
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(todo_list, :halt), do: :ok
end

defmodule TodoList.CsvImporter do
  def import(file_path) do
    File.stream!(file_path)
    |> Stream.map(&(String.replace(&1, "\n", "")))
    |> Stream.map(&(split_record &1))
    |> Enum.to_list
    |> TodoList.new
  end

  def split_record(item) do
    item
    |> String.split(",")
    |> Stream.map(&(String.split(&1, "/")))
    |> Stream.map(&(process_item &1))
    |> Enum.to_list
    |> List.to_tuple
  end



  def process_item([item]) do
    item
  end

  def process_item([year, month, day] = date) do
    Enum.map(date, &(String.to_integer &1))
    |> List.to_tuple
  end


end
