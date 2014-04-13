defmodule Mailman.TestingAdapter do

  def deliver(_, email) do
    message = Mailman.Emails.render(email)
    { :ok, message }
  end
  
end
