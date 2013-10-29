defmodule MailmanTest do
  use ExUnit.Case

  defmodule UserMailer do
    use Mailman
  end

  def build_test_envelope do
    UserMailer.new to: "someone@elixir.com", from: "test@elixir.com", user: "Tasty Tester"
  end

  test "the deliver without a to raises an exception" do
    assert_raise Mailman.InvalidEnvelopeException, "The envelope should have the recipient", fn ->
      Mailman.deliver(UserMailer.new({}))
    end
  end
end
