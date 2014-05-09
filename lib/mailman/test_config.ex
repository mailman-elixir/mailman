defmodule Mailman.TestConfig do
  defstruct raise_errors: false

end

defimpl Mailman.Adapter, for: Mailman.TestConfig do
  def deliver(config, email, message) do
    Mailman.TestingAdapter.deliver(config, email, message)
  end
end
