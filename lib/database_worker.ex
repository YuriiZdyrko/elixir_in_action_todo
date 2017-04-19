defmodule Todo.DatabaseWorker do
  use GenServer
  import IEx

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

  def handle_call({:store, key, val}, _from, _state) do
    IO.puts(":store on DatabaseWorker #{inspect self()}")
    File.mkdir(Path.join(@db_folder, Atom.to_string(node()))) 
    file_path = Path.join(@db_folder, Atom.to_string(node())) |> Path.join(key)
    if !File.exists?(file_path) do
      :ok = File.touch(file_path)
    end
    File.write(file_path, :erlang.term_to_binary(val))
    {:reply, :ok, nil}
  end

  def handle_call({:get, key}, caller, _) do
    file_path = Path.join(@db_folder, Atom.to_string(node())) |> Path.join(key)
    spawn(fn ->
      data = case File.read(file_path) do
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
    pid = Registry.whereis_name({:database_worker, worker_id})
    GenServer.call(pid, {:store, key, data})

    # v1 GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    pid = Registry.whereis_name({:database_worker, worker_id})
    GenServer.call(pid, {:get, key})

    # v1 GenServer.call(via_tuple(worker_id), {:get, key})
  end


  defp via_tuple(worker_id) do
    # And the tuple always follow the same format:
    # {:via, module_name, term}

    {:via, Registry, {:database_worker, worker_id}}

    # v1 {:via, Todo.ProcessRegistry, {:database_worker, worker_id}}
  end
end
