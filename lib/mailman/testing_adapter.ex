defmodule Mailman.TestingAdapter do

  def deliver(_, email, message) do
    Task.async fn ->
      Mailman.TestServer.register_delivery message
      { :ok, message }
    end
  end

end
