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
  def new, do: MultiDict.new

  def add_entry(todolist, k, v) do
    MultiDict.add(todolist, k, v)
  end

  def entries(todolist, k) do
    MultiDict.get(todolist, k)
  end
end

l = TodoList.new
|> TodoList.add_entry({2013, 12, 19}, "Dentist") 
|> TodoList.add_entry({2013, 12, 20}, "Shopping") 
|> TodoList.add_entry({2013, 12, 19}, "Movies")


defmodule Fraction do
  defstruct a: nil, b: nil

  def new(a, b) do
    %Fraction{a: a, b: b}
  end

  def value(%Fraction{a: a, b: b}) do
    a / b
  end

  def add(%Fraction{a: a1, b: b1}, %Fraction{a: a2, b: b2}) do
    new (a1 * b2 + a2 * b1, b2 * b1)
  end
end
