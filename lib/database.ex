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
    {results, bad_nodes} =
      :rpc.multicall(
        __MODULE__, :store_local, [key, val],
        :timer.seconds(5)
      )
    IO.puts("Results of rpc:store #{inspect results}")
    Enum.each(bad_nodes, &IO.puts("Store failed on node #{inspect &1}"))
    :ok
  end

  def store_local(key, val) do
    DatabaseWorker.store(get_id_suffix(key), key, val)
  end

  def get(key) do
    DatabaseWorker.get(get_id_suffix(key), key)
  end
end
