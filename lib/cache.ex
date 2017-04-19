defmodule Todo.Cache do

  @doc """
  Get server process pid by todo_list_name.
  If none is found - start new one
  """
  def create_server(todo_list_name) do
    case Todo.ServerSupervisor.start_child(todo_list_name) do
      {:error, {:already_started, pid}} -> pid
      {:ok, pid} -> pid
    end
  end

  def server_process(todo_list_name) do
    case Todo.Server.whereis(todo_list_name) do
      :undefined -> create_server(todo_list_name)
      pid -> pid
    end
  end
end
