defmodule Mailman.TestServerSupervisor do
  @moduledoc "A DynamicSupervisor to manage TestServers, which can get started ad-hoc"
  use DynamicSupervisor

  def start_link() do
    :ets.new(:mailman_test_servers, [:set, :public, :named_table])
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_test_server(parent_pid) do
    child_spec = {Mailman.TestServer, {[], parent_pid}}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
