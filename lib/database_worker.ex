defmodule Todo.DatabaseWorker do
  use GenServer

  @db_folder "./db"

  @doc """
  Worker ID can be worker_0..worker_2
  """
  def start_link(id_suffix) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, [])
    Process.register(pid, :"worker_#{id_suffix}")
  end

  def init() do
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

  def terminate(reason, _status) do
    IO.puts("Worker termination: #{inspect reason}")
  end

  def store(id_suffix, key, data) do
    GenServer.cast(:"worker_#{id_suffix}", {:store, key, data})
  end

  def get(id_suffix, key) do
    GenServer.call(:"worker_#{id_suffix}", {:get, key})
  end
end
