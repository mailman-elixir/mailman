defmodule MailmanTest do
  use ExUnit.Case, async: true

  setup_all do
    pid = Mailman.TestServer.start
    :ok
  end

  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config)
    end

    def config do
      %Mailman.Context{
          config:   %Mailman.TestConfig{},
          composer: %Mailman.EexComposeConfig{}
        }
    end
  end

  def testing_email do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      to: [ "ciemniewski.kamil@gmail.com" ],
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
      to: [ "ciemniewski.kamil@gmail.com", "kamil@endpoint.com" ],
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
    { :ok, _  } = Mailman.Email.parse message
  end

  test "#deliver returns Task" do
    assert MyApp.Mailer.deliver(testing_email).__struct__ == Task
  end

  test "encodes attachements properly" do
    {:ok, message} = Task.await MyApp.Mailer.deliver(email_with_attachments)
    email = Mailman.Email.parse! message
    assert email.from == email_with_attachments.from
    assert email.to   == Mailman.Render.normalize_addresses(email_with_attachments.to)
    assert email.subject   == email_with_attachments.subject
    assert email.cc   == Mailman.Render.normalize_addresses(email_with_attachments.cc)
    assert email.bcc   == Mailman.Render.normalize_addresses(email_with_attachments.bcc)
    assert email.text   == email_with_attachments.text
    assert_same_attachments email, email_with_attachments
  end

  test "the message sent queue contains the latest sent messages" do
    Mailman.TestServer.clear_deliveries
    { :ok, _ } = Task.await MyApp.Mailer.deliver(email_with_attachments)
    assert (Mailman.TestServer.deliveries |> Enum.count) == 1
    { :ok, _ } = Task.await MyApp.Mailer.deliver(testing_email)
    assert (Mailman.TestServer.deliveries |> Enum.count) == 2
    Mailman.TestServer.clear_deliveries
    assert (Mailman.TestServer.deliveries |> Enum.count) == 0
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
