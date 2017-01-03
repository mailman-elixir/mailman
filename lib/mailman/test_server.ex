defmodule Mailman.TestServer do
  @moduledoc "Implementation of the testing SMTP server"

  use GenServer
  require Logger

  @doc """
  Sets "global" mode.

  When "global" mode is enabled, the calling process is ignored and a global
  TestServer is used instead. Use this when you need to test e-mail sending
  across multiple processes. Keep in mind that this is not async-safe, and you
  should specify `async: false` when using ExUnit.
  """
  @spec set_global_mode!(boolean) :: boolean
  def set_global_mode!(toggle) do
    Application.put_env(:mailman, :global_mode, toggle, persistent: true)
    _ = deliveries()
    toggle
  end

  @doc """
  Starts the TestServer supervisor. Provided for compatibility.

  Mailman.TestServerSupervisor.start_link/0 is preferred, typically in your
  `test_helper.exs` file.
  """
  def start do
    Mailman.TestServerSupervisor.start_link
  end

  def start_link(initial_state, parent_pid) do
    GenServer.start_link(__MODULE__, {initial_state, parent_pid}, [])
  end

  def deliveries, do: deliveries(self())
  def deliveries(pid) do
    GenServer.call(pid_for(pid), :list)
  end

  def register_delivery(message), do: register_delivery(self(), message)
  def register_delivery(pid, message) do
    GenServer.cast(pid_for(pid), {:push, message})
  end

  def clear_deliveries, do: clear_deliveries(self())
  def clear_deliveries(pid) do
    GenServer.call(pid_for(pid), :clear_deliveries)
  end

  defp pid_for(parent_pid) do
    if Application.get_env(:mailman, :global_mode, false) do
      get_pid_for(:global_server)
    else
      unless Process.alive?(parent_pid),
        do: raise(ArgumentError, "parent pid is not alive")
      get_pid_for(parent_pid)
    end
  end

  defp get_pid_for(parent_pid) do
    case :ets.lookup(:mailman_test_servers, parent_pid) do
      [] ->
        {:ok, pid} = Mailman.TestServerSupervisor.start_test_server(parent_pid)
        pid
      [{_parent_pid, pid}] ->
        pid
    end
  end

  def init({state, pid}) do
    :ets.insert(:mailman_test_servers, {pid, self()})
    if is_pid(pid), do: Process.monitor(pid)
    {:ok, state}
  end

  def handle_cast({:push, message}, rest) do
    {:noreply, [message|rest]}
  end

  def handle_call(:list, _, state) do
    {:reply, state, state}
  end

  def handle_call(:clear_deliveries, _, _state) do
    {:reply, :ok, []}
  end

  def handle_info({:'DOWN', _ref, _type, remote_pid, _info}, _state) do
    :ets.delete(:mailman_test_servers, remote_pid)
    {:stop, :normal, []}
  end
end
