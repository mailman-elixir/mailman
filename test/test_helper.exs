ExUnit.start

defrecord User, name: "Testy", lastname: "Tester", email: "tester3@tester.com"

defmodule Mailer do
  use Mailman.Mailer, adapter: Mailman.TestingAdapter
end

defmodule MyApp do
  defmodule EmailsComposer do
    def templates_root do
      "test/views"
    end
  end
end

defmodule UserEmails do
  use Mailman.Emails, composer: MyApp.EmailsComposer

  default_from "testy@elixir.com"

    compose :welcome, user do
      subject  "Welcome aboard!"
      to       [ user.email ]
      data :name,     user.name
      data :lastname, user.lastname
    end

    compose :are_you_there, user do
      from     "shaggy@elixir.com"
      to       [ user.email ]
      subject  "Where are you scooby doo?"
      data     :name, user.name
    end

    compose :i_am_many, user do
      from "almighty@elixir.com"
      to [ user.email ]
      subject "Ho ho ho"
      data :name, user.name
    end

    compose :unicode_message, data do
      from "tester@tester.com"
      to [ "tester2@tester.com" ]
      subject "Unicode test"
      data :name, ""
    end

end

defmodule TestingMailers do

  def build_test_envelope(name // "Testy") do
    { :ok, envelope } = UserEmails.get :welcome, User.new(name: name)
    envelope
  end

end
