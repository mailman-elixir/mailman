defmodule Mailman.TestingAdapter do

  def deliver(_, email, message) do
    Task.async fn ->
      { :ok, message }
    end
  end
  
end
