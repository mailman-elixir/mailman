defmodule MailmanTest do
  use ExUnit.Case

  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config)
    end

    def config do
      %Mailman.Context{
          config: %Mailman.TestConfig{},
          composer: %Mailman.EexComposeConfig{
            root_path: "test/views"
            }
        }
    end
  end

  test "it works" do
    {:ok, message} = Task.await MyApp.Mailer.deliver(testing_email)
    IO.puts message
  end

  def testing_email do
    %Mailman.Email{
      name: "hello",
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      to: [ "testy@tester123456.com" ],
      cc: [ "testy2#tester1234.com", "abcd@defd.com" ],
      bcc: [ "1234@wsd.com" ],
      data: [
        name: "Yo"
        ]
      }
  end

end
