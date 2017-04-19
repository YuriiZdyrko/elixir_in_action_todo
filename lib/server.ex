defmodule Todo.Server do
  use GenServer
  alias Todo.Database

  def start_link(list_name) do
    GenServer.start_link(
      Todo.Server,
      list_name,
      name: {:global, {:todo_server, list_name}}
    )

    # GenServer.start_link(Todo.Server, list_name, name: via_tuple(list_name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def whereis(name) do
    :global.whereis_name({:todo_server, name})

    # v2 Registry.whereis_name({:database_worker, name})

    # v1 Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end


  def init(todo_list_name) do
    {:ok, {todo_list_name, Database.get(todo_list_name)}}
  end

  def handle_cast({:add_entry, new_entry}, {name, list}) do
    new_list = Todo.List.add_entry(list, new_entry)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_call({:entries, date}, _, {name, list}) do
    {
      :reply,
      Todo.List.entries(Database.get(name), date),
      {name, list}
    }
  end

  def terminate(reason, _status) do
    IO.puts("Server termination: #{inspect reason}")
  end
end
