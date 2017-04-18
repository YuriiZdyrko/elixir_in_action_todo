defmodule Todo.Cache do

  use GenServer

  @cache __MODULE__

  def start_link do
    IO.puts("Starting Todo.Cache")
    GenServer.start_link(__MODULE__, nil, [name: @cache])
  end

  def init(_) do
    {:ok, nil}
  end

  @doc """
  Get server process pid by todo_list_name.
  If none is found - start new one
  """
  def handle_call({:server_process, todo_list_name}, _, _) do
    server_pid = case Todo.Server.whereis(todo_list_name) do
      :undefined ->
        {:ok, pid} = Todo.ServerSupervisor.start_child(todo_list_name)
        pid
      pid -> pid
    end
    {
      :reply,
      server_pid,
      nil
    }
  end

  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      :undefined ->
        # There's no to-do server, so we'll issue request to the cache process.
        GenServer.call(@cache, {:server_process, todo_list_name})

      pid -> pid
    end
  end
end
