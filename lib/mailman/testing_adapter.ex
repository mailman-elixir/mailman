defmodule Mailman.TestingAdapter do
  @moduledoc "Implementation of the testing SMTP adapter"

  def deliver(config, _email, message) do
    parent = self
    Task.async fn ->
      if config.store_deliveries do
        Mailman.TestServer.register_delivery(parent, message)
      end
      { :ok, message }
    end
  end

end
