defmodule Todo.DatabaseWorker do
  use GenServer

  @db_folder "./db"

  @doc """
  Worker ID can be worker_0..worker_2
  """
  def start_link(id_suffix) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(id_suffix))
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:store, key, val}, _) do
    IO.puts(":store on DatabaseWorker #{inspect self()}")
    file_path = Path.join(@db_folder, key)
    if !File.exists?(file_path) do
      :ok = File.touch(file_path)
    end
    File.write(file_path, :erlang.term_to_binary(val))
    {:noreply, nil}
  end

  def handle_call({:get, key}, caller, _) do
    spawn(fn ->
      data = case File.read(Path.join(@db_folder, key)) do
        {:ok, binary} ->
          :erlang.binary_to_term(binary)
        {:error, _} ->
          %Todo.List{}
      end
      GenServer.reply(caller, data)
    end)
    {:noreply, nil}
  end

  def handle_info(msg, state) do
    IO.puts("TodoDatabase:handle_info #{msg}")
    {:noreply, state}
  end

  def terminate(reason, _status) do
    IO.puts("Worker termination: #{inspect reason}")
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end


  defp via_tuple(worker_id) do
    # And the tuple always follow the same format:
    # {:via, module_name, term}
    {:via, Todo.ProcessRegistry, {:database_worker, worker_id}}
  end
end
