defmodule Todo do

  use Application

  def start(_type, _args) do
    Todo.CacheSupervisor.start_link()
  end

end
