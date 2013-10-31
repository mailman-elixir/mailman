defmodule MailmanTest do
  use ExUnit.Case
  import TestingMailers

  test "defemail returns a record of envelope" do
    assert is_record(build_test_envelope, Mailman.Envelope)
  end

  test "mailer has a send method" do
    assert build_test_envelope.header.subject != nil
    { status, emails } = Mailer.send(build_test_envelope)
    assert status == :ok
  end

  test "envelope has a body that is a record" do
    assert is_record(build_test_envelope.body, Mailman.EnvelopeBody)
  end

  test "envelope has a text body" do
    assert build_test_envelope.body.text == "Hello Testy Tester! These are Unicode: qżźół\n"
    assert build_test_envelope("Second").body.text == "Hello Second Tester! These are Unicode: qżźół\n"
  end

  test "envelope has a from field in a header" do
    assert build_test_envelope.header.from == "testy@elixir.com"
  end

  test "there is a from function inside the mail composer" do
    assert elem(UserEmails.get(:are_you_there, User.new(name: "Scooby")),1).header.from == "shaggy@elixir.com"
  end

  test "sending emails work" do
    user = User.new(name: "Scooby")
    { status, emails } = UserEmails.get(:are_you_there, user) |> elem(1) |> Mailer.send
    assert status == :ok
    assert Enum.count(emails) == 1
    { to, message } = List.first emails
    assert to == user.email
  end

end
