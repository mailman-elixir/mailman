defmodule Mailman.TestConfig do
  @moduledoc "Config struct for the testing adapter"

  defstruct store_deliveries: true
end

defimpl Mailman.Adapter, for: Mailman.TestConfig do
  def deliver(config, email, message, opts \\ []) do
    Mailman.TestingAdapter.deliver(config, email, message, opts)
  end
end
