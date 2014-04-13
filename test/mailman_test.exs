defmodule MailmanTest do
  use ExUnit.Case

  defimpl Mailman.Mailer, for: Mailman.Email do
    def config(email) do
      Mailman.TestConfig[
      ]
    end
  end

  defimpl Mailman.Composer, for: Mailman.Email do
    def root_path(email) do
      "test/views"
    end
  end

  test "it works" do
    Mailman.deliver testing_email
  end

  def testing_email do
    Mailman.Email[
      name: "hello",
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      to: [ "testy@tester123456.com" ],
      data: [
        name: "Yo"
        ]
      ]
  end

end
