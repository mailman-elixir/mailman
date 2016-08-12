defmodule Mailman.TestServerSupervisor do
  use Supervisor

  def start_link do
    :ets.new(:mailman_test_servers, [:set, :public, :named_table])
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_test_server(parent_pid) do
    Supervisor.start_child(__MODULE__, [parent_pid])
  end

  def init([]) do
    children = [
      worker(Mailman.TestServer, [[]], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
