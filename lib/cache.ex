defmodule Todo.Cache do

  use GenServer

  alias Todo.Database

  @cache __MODULE__

  def start_link do
    IO.puts("Starting Todo.Cache")
    Database.start_link()
    GenServer.start_link(__MODULE__, nil, [name: @cache])
  end

  def init(_) do
    {:ok, %{}}
  end

  @doc """
  Get server process pid by todo_list_name.
  If none is found - start new one
  """
  def handle_call({:server_process, todo_list_name}, _, servers) do
    case Map.get(servers, todo_list_name) do
      nil ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)
        {
          :reply,
          new_server,
          Map.put(servers, todo_list_name, new_server)
        }

      value ->
        {:reply, value, servers}
    end
  end

  def server_process(todo_list_name) do
    GenServer.call(@cache, {:server_process, todo_list_name})
  end
end
