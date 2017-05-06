defmodule Todo.Database do
  use GenServer

  def start_link(db_folder) do
    IO.puts "starting database server"
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    get_worker(key)
    |> GenServer.cast({:store, key, data})
  end

  def get(key) do
    get_worker(key)
    |> GenServer.call({:get, key})
  end

  def init(db_folder) do
    File.mkdir_p(db_folder)
    {:ok, worker1} = Todo.DatabaseWorker.start_link(db_folder)
    {:ok, worker2} = Todo.DatabaseWorker.start_link(db_folder)
    {:ok, worker3} = Todo.DatabaseWorker.start_link(db_folder)

    workers = HashDict.new
    |> HashDict.put(0, worker1)
    |> HashDict.put(1, worker2)
    |> HashDict.put(2, worker3)
    {:ok, {db_folder, workers}}
  end

  def get_worker(key) do
    GenServer.call(:database_server, {:get_worker, key})
  end

  def handle_call({:get_worker, key},_, {db_folder, workers}) do
    worker_id = :erlang.phash2(key, 3)
    {:reply, workers[worker_id], {db_folder, workers}}
  end

  def handle_cast({:store, key, data}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data = case File.read(file_name(db_folder, key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
  
end
