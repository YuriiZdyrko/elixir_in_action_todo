defmodule Todo.Database do

  alias Todo.DatabaseWorker

  @pool_size 2

  def start_link do
    IO.puts("Starting Todo.Database")
    Todo.PoolSupervisor.start_link(@pool_size)
  end

  def init(_) do
    {:ok, nil}
  end

  def get_id_suffix(list_name) do
    :erlang.phash2(list_name, @pool_size)
  end

  def store(key, val) do
    DatabaseWorker.store(get_id_suffix(key), key, val)
  end

  def get(key) do
    DatabaseWorker.get(get_id_suffix(key), key)
  end
end
