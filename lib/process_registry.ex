defmodule Todo.ProcessRegistry do

  use GenServer
  import Kernel, except: [send: 2]

  @me __MODULE__

  def start_link do
    IO.puts("Starting Todo.ProcessRegistry")
    GenServer.start_link(__MODULE__, nil, [name: @me])
  end

  def init(_) do
    {:ok, %{}}
  end

  def whereis_name(name) do
    GenServer.call(@me, {:whereis_name, name})
  end

  def register_name(name, pid) do
    GenServer.call(@me, {:register_name, name, pid})
  end

  def unregister_name(name) do
    GenServer.cast(@me, {:unregister_name, name})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
    pid ->
      Kernel.send(pid, message)
      pid
    end
  end

  def handle_call({:register_name, name, pid}, _from, state) do
    # If no process by key - register
    IO.puts("Process registry :register_name #{inspect name}")
    case Map.get(state, name) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(state, name, pid)}
      _ ->
        {:reply, :no, state}
    end
  end

  def handle_call({:whereis_name, key}, _from, state) do
    {:reply, Map.get(state, key, :undefined), state}
  end

  def handle_cast({:unregister_name, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  def handle_info(unexpected, state) do
    IO.puts("Unexpected message in process registry: #{inspect unexpected}")
    {:noreply, state}
  end

  defp deregister_pid(process_registry, pid) do
    # We'll walk through each {key, value} item, and delete those elements whose
    # value is identical to the provided pid.
    Enum.reduce(
      process_registry,
      process_registry,
      fn
        ({registered_alias, registered_process}, registry_acc) when registered_process == pid ->
          Map.delete(registry_acc, registered_alias)

        (_, registry_acc) -> registry_acc
      end
    )
  end

end
