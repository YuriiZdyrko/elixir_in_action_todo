defmodule Todo.CacheSupervisor do

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      # v1 worker(Todo.ProcessRegistry, []),
      supervisor(Registry, [:unique, :todo_server], [id: :server_registry]),
      supervisor(Registry, [:unique, :database_worker], [id: :worker_registry]),
      supervisor(Todo.SystemSupervisor, [])
    ]
    supervise(processes, strategy: :rest_for_one)
  end
end
