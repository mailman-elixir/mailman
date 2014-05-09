defmodule Mailman.TestingAdapter do

  def deliver(_, email, message) do
    { :ok, message }
  end
  
end
