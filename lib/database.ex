defmodule Todo.Database do

  use GenServer
  import Todo.List
  alias Todo.DatabaseWorker

  @db_folder "./db"
  @db __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, nil, [name: @db])
  end

  def init(_) do
    IO.puts("Todo.Database init")
    File.mkdir(@db_folder)
    spawn_workers()
    {:ok, nil}
  end

  def handle_cast({:store, key, val}, _) do
    DatabaseWorker.store(get_id_suffix(key), key, val)
    {:noreply, nil}
  end

  def handle_call({:get, key}, _caller, _) do
    result = DatabaseWorker.get(get_id_suffix(key), key)
    {:reply, result, nil}
  end

  def handle_info(msg, _state) do
    IO.puts("TodoDatabase:handle_info #{msg}")
  end

  def terminate(reason, _status) do
    IO.puts("Database termination: #{inspect reason}")
  end

  def get_id_suffix(list_name) do
    :erlang.phash2(list_name, 3)
  end

  def spawn_workers do
    DatabaseWorker.start_link(0)
    DatabaseWorker.start_link(1)
    DatabaseWorker.start_link(2)
  end

  def store(key, data) do
    GenServer.cast(@db, {:store, key, data})
  end

  def get(key) do
    GenServer.call(@db, {:get, key})
  end
end
