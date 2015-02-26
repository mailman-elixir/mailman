defmodule Mailman.TestServer do
  use GenServer
  require Logger

  def start do
    GenServer.start_link(__MODULE__, [], name: TestingSmtpServer)
  end

  def deliveries do
    GenServer.call(TestingSmtpServer, :list)
  end

  def register_delivery(message) do
    GenServer.cast(TestingSmtpServer, {:push, message})
  end

  def clear_deliveries do
    GenServer.call(TestingSmtpServer, :clear_deliveries)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:push, message}, rest) do
    {:noreply, [message|rest]}
  end

  def handle_call(:list, _, state) do
    {:reply, state, state}
  end

  def handle_call(:clear_deliveries, _, state) do
    {:reply, :ok, []}
  end

end
