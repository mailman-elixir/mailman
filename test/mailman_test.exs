defmodule MailmanTest do
  use ExUnit.Case, async: true

  setup_all do
    pid = :gen_smtp_server.start :smtp_server_example, 
      [[], [{:allow_bare_newlines, :true}, {:port, 1234}]]
    :ok
  end

  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config)
    end

    def config do
      %Mailman.Context{
          config:   %Mailman.LocalSmtpConfig{ port: 1234 }, #   %Mailman.TestConfig{},
          composer: %Mailman.EexComposeConfig{}
        }
    end
  end

  def testing_email do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      to: [ "testy@tester123456.com" ],
      cc: [ "testy2#tester1234.com", "abcd@defd.com" ],
      bcc: [ "1234@wsd.com" ],
      data: [
        name: "Yo"
        ],
      text: "Hello! <%= name %> These are Unicode: qżźół",
      html: """
<html>
<body>
 <b>Hello! <%= name %></b> These are Unicode: qżźół
</body>
</html>
      """
      }
  end

  def email_with_attachments do
    %Mailman.Email{
      subject: "Pictures!",
      from: "mailman@elixir.com",
      to: [ "testy@tester.com", "testy2@tester.com" ],
      cc: [],
      bcc: [],
      attachments: [
        Mailman.Attachment.inline!("test/data/blank.png")
        ],
      text: "Pictures!",
      html: """
<html>
<body>
Pictures!
</body>
</html>
      """
      }
  end

  test "sending testing emails works" do
    { :ok, message } = Task.await MyApp.Mailer.deliver(testing_email)
    { :ok, parsed  } = Mailman.Email.parse message
  end

  test "#deliver returns Task" do
    assert MyApp.Mailer.deliver(testing_email).__struct__ == Task
  end

  test "encodes attachements properly" do
    {:ok, message} = Task.await MyApp.Mailer.deliver(email_with_attachments)
    email = Mailman.Email.parse! message
    assert email.from == email_with_attachments.from
    assert email.to   == email_with_attachments.to
    assert email.subject   == email_with_attachments.subject
    assert email.cc   == email_with_attachments.cc
    assert email.bcc   == email_with_attachments.bcc
    assert email.text   == email_with_attachments.text
    assert_same_attachments email, email_with_attachments
  end

  def assert_same_attachments(email1, email2) do
    assert Enum.count(email1.attachments) == Enum.count(email2.attachments)
    Enum.each email1.attachments, fn(attachment) ->
      found = Enum.find email2.attachments, fn(a) ->
        a.data == attachment.data &&
          a.mime_type == attachment.mime_type &&
          a.mime_sub_type == attachment.mime_sub_type
      end
      assert found != nil
      assert found.file_path == Path.basename(found.file_path)
    end
  end

end
