defmodule Mailman.TestServerTest do
  use ExUnit.Case, async: false

  alias Mailman.TestServer

  setup do
    on_exit fn ->
      TestServer.set_global_mode! false
    end
    :ok
  end

  test "asynchronous calls to TestServer don't interfere with each other" do
    tasks =
      for i <- 1..10 do
        Task.async(fn ->
          TestServer.register_delivery({:test, i})
          :timer.sleep(i * 20)
          deliveries = TestServer.deliveries
          {(deliveries == [{:test, i}]), i, deliveries}
        end)
      end
    tasks_with_results = Task.yield_many(tasks, 5000)
    results = Enum.map(tasks_with_results, fn {task, res} ->
      # Shutdown the tasks that did not reply nor exit
      res || Task.shutdown(task, :brutal_kill)
    end)
    for {:ok, {true_or_false, i, deliveries}} <- results do
      assert true_or_false == true, "iteration ##{i} failed; found #{inspect deliveries}"
    end
  end

  test "a TestServer for a particular process is destroyed after that process exits" do
    task = Task.async(fn ->
      TestServer.register_delivery({:test, 1})
    end)
    Task.await(task)
    assert_raise ArgumentError, "parent pid is not alive", fn ->
      TestServer.deliveries(task.pid)
    end
  end

  test "global mode works" do
    TestServer.set_global_mode! true

    for i <- 1..10 do
      Task.async(fn ->
        TestServer.register_delivery({:test, i})
        :timer.sleep(i * 20)
        :ok
      end)
    end |> Enum.each(&Task.await/1)

    assert length(TestServer.deliveries) == 10
  end
end
