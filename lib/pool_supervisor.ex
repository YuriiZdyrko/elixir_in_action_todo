defmodule Todo.PoolSupervisor do

  use Supervisor

  def start_link(pool_size) do
    Supervisor.start_link(__MODULE__, pool_size)
  end

  def init(pool_size) do
    workers = 0..pool_size
    |> Enum.map(fn(worker_id) ->
      worker(
        Todo.DatabaseWorker,
        [worker_id],

        # This is required by Supervisor to distinguish workers
        id: {:database_worker, worker_id}
      )
    end)

    supervise(workers, strategy: :one_for_one)
  end

end
