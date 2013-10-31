defmodule Mailman.TestingAdapter do
  use Mailman.Adapter
  
  def deliver(envelope) do
    { :ok, Mailman.render(envelope) }
  end
end
