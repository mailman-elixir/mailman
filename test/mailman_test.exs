defmodule MailmanTest do
  use ExUnit.Case, async: true

  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config())
    end

    def deliver(email, :send_cc_and_bcc) do
      Mailman.deliver(email, config(), :send_cc_and_bcc)
    end

    def config do
      %Mailman.Context{
        config: %Mailman.TestConfig{},
        composer: %Mailman.EexComposeConfig{}
      }
    end
  end

  def testing_email do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      reply_to: "reply@example.com",
      to: ["ciemniewski.kamil@gmail.com"],
      cc: ["testy2#tester1234.com", "abcd@defd.com"],
      bcc: ["1234@wsd.com"],
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

  def cc_and_bcc_testing_email do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      reply_to: "reply@example.com",
      to: ["ciemniewski.kamil@gmail.com"],
      cc: ["abcd@defd.com"],
      bcc: ["1234@wsd.com", "5678@wsd.com"],
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
      reply_to: "reply@example.com",
      to: ["ciemniewski.kamil@gmail.com", "kamil@endpoint.com"],
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
    {:ok, message} = MyApp.Mailer.deliver(testing_email())
    {:ok, _} = Mailman.Email.parse(message)
  end

  test "parsing sent emails works" do
    {:ok, message} = MyApp.Mailer.deliver(testing_email())
    {:ok, parsed_email} = Mailman.Email.parse(message)

    # Un-comment this to investigate problems with parsing
    # IO.inspect(parsed_email)

    assert true
  end

  test "#deliver/2 returns list of Tasks if it includes :send_cc_and_bcc atom" do
    assert MyApp.Mailer.deliver(testing_email(), :send_cc_and_bcc) |> is_list == true

    assert MyApp.Mailer.deliver(testing_email(), :send_cc_and_bcc) |> List.first() |> is_tuple ==
             true
  end

  test "#deliver/2 sends emails to all address in CC and BCC list" do
    cc_and_bcc_testing_email = cc_and_bcc_testing_email()
    Mailman.TestServer.clear_deliveries()
    MyApp.Mailer.deliver(cc_and_bcc_testing_email, :send_cc_and_bcc)
    assert Mailman.TestServer.deliveries() |> Enum.count() == 4
  end

  test "#deliver/2 redactes the BCC email from the TO message" do
    cc_and_bcc_testing_email = cc_and_bcc_testing_email()
    Mailman.TestServer.clear_deliveries()
    MyApp.Mailer.deliver(cc_and_bcc_testing_email, :send_cc_and_bcc)
    to_email = Mailman.TestServer.deliveries() |> List.last() |> Mailman.Email.parse!()
    assert to_email.bcc == []
  end

  test "#deliver/2 adds the BCC email to a BCC receiver" do
    cc_and_bcc_testing_email = cc_and_bcc_testing_email()
    Mailman.TestServer.clear_deliveries()
    MyApp.Mailer.deliver(cc_and_bcc_testing_email, :send_cc_and_bcc)
    bcc_email = Mailman.TestServer.deliveries() |> List.first() |> Mailman.Email.parse!()
    assert bcc_email.to == Mailman.Render.normalize_addresses(cc_and_bcc_testing_email.to)
    assert bcc_email.bcc |> length == 1
  end

  test "encodes attachments properly" do
    email_with_attachments = email_with_attachments()
    {:ok, message} = MyApp.Mailer.deliver(email_with_attachments)
    email = Mailman.Email.parse!(message)
    assert email.from == email_with_attachments.from
    assert email.reply_to == email_with_attachments.reply_to
    assert email.to == Mailman.Render.normalize_addresses(email_with_attachments.to)
    assert email.subject == email_with_attachments.subject
    assert email.cc == Mailman.Render.normalize_addresses(email_with_attachments.cc)
    assert email.bcc == Mailman.Render.normalize_addresses(email_with_attachments.bcc)
    assert email.text == email_with_attachments.text
    assert email.html == email_with_attachments.html
    assert_same_attachments(email, email_with_attachments)
  end

  test "the message sent queue contains the latest sent messages" do
    email_with_attachments = email_with_attachments()
    Mailman.TestServer.clear_deliveries()
    {:ok, _} = MyApp.Mailer.deliver(email_with_attachments)
    assert Mailman.TestServer.deliveries() |> Enum.count() == 1
    {:ok, _} = MyApp.Mailer.deliver(testing_email())
    assert Mailman.TestServer.deliveries() |> Enum.count() == 2
    Mailman.TestServer.clear_deliveries()
    assert Mailman.TestServer.deliveries() |> Enum.count() == 0
  end

  test "Ensure attachments are encoded and decoded properly" do
    email_with_attachments = email_with_attachments()
    {:ok, attachment} = "test/data/blank.png" |> Path.expand() |> File.read()

    {:ok, email} =
      Mailman.Render.render(email_with_attachments, %Mailman.EexComposeConfig{})
      |> Mailman.Parsing.parse()

    assert attachment == email.attachments |> hd |> Map.get(:data)
  end

  test "Render with extra email headers" do
    rendered_email =
      Mailman.Render.render(testing_email(), %Mailman.EexComposeConfig{}, [
        {"X-Test-Header", "123"}
      ])

    # Just check whether it contains it for now
    rendered_email =~ "X-Test-Header: 123"
  end

  def assert_same_attachments(email1, email2) do
    assert Enum.count(email1.attachments) == Enum.count(email2.attachments)

    Enum.each(email1.attachments, fn attachment ->
      found =
        Enum.find(email2.attachments, fn a ->
          a.data == attachment.data &&
            a.mime_type == attachment.mime_type &&
            a.mime_sub_type == attachment.mime_sub_type
        end)

      assert found != nil
      assert found.file_name == Path.basename(found.file_name)
    end)
  end

  defmodule MyApp.ExternalTextMailer do
    def deliver(email) do
      Mailman.deliver(email, config())
    end

    def config do
      %Mailman.Context{
        config: %Mailman.TestConfig{},
        composer: %Mailman.EexComposeConfig{
          text_file: true
        }
      }
    end
  end

  def email_with_external_text do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      reply_to: "reply@example.com",
      to: ["ciemniewski.kamil@gmail.com"],
      cc: ["testy2#tester1234.com", "abcd@defd.com"],
      bcc: ["1234@wsd.com"],
      data: [
        name: "Yo"
      ],
      text: "test/templates/email.txt.eex",
      html: """
      <html>
      <body>
      <b>Hello! <%= name %></b> These are Unicode: qżźół
      </body>
      </html>
      """
    }
  end

  test "should load text part of email from external file" do
    email_with_external_text = email_with_external_text()
    {:ok, message} = MyApp.ExternalTextMailer.deliver(email_with_external_text)
    email = Mailman.Email.parse!(message)

    assert email.text ==
             EEx.eval_file(
               email_with_external_text.text,
               email_with_external_text.data
             )
  end

  defmodule MyApp.ExternalHTMLMailer do
    def deliver(email) do
      Mailman.deliver(email, config())
    end

    def config do
      %Mailman.Context{
        config: %Mailman.TestConfig{},
        composer: %Mailman.EexComposeConfig{
          html_file: true
        }
      }
    end
  end

  def email_with_external_html do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      reply_to: "reply@example.com",
      to: ["ciemniewski.kamil@gmail.com"],
      cc: ["testy2#tester1234.com", "abcd@defd.com"],
      bcc: ["1234@wsd.com"],
      data: [
        name: "Yo"
      ],
      text: "Hello! <%= name %> These are Unicode: qżźół",
      html: "test/templates/email.html.eex"
    }
  end

  test "should load html part of email from external file" do
    email_with_external_html = email_with_external_html()
    {:ok, message} = MyApp.ExternalHTMLMailer.deliver(email_with_external_html)
    email = Mailman.Email.parse!(message)

    assert email.html ==
             EEx.eval_file(
               email_with_external_html.html,
               email_with_external_html.data
             )
  end

  defmodule MyApp.ExternalTemplatesMailer do
    def deliver(email) do
      Mailman.deliver(email, config())
    end

    def config do
      %Mailman.Context{
        config: %Mailman.TestConfig{},
        composer: %Mailman.EexComposeConfig{
          html_file: true,
          text_file: true,
          html_file_path: "test/templates/",
          text_file_path: "test/templates/"
        }
      }
    end
  end

  def email_with_template_paths do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      reply_to: "reply@example.com",
      to: ["ciemniewski.kamil@gmail.com"],
      cc: ["testy2#tester1234.com", "abcd@defd.com"],
      bcc: ["1234@wsd.com"],
      data: [
        name: "Yo"
      ],
      text: "email.txt.eex",
      html: "email.html.eex"
    }
  end

  test "should load email parts from external file based on x_file_path" do
    email_with_template_paths = email_with_template_paths()
    {:ok, message} = MyApp.ExternalTemplatesMailer.deliver(email_with_template_paths)
    email = Mailman.Email.parse!(message)

    assert email.html ==
             EEx.eval_file(
               "test/templates/#{email_with_template_paths.html}",
               email_with_template_paths.data
             )

    assert email.text ==
             EEx.eval_file(
               "test/templates/#{email_with_template_paths.text}",
               email_with_template_paths.data
             )
  end

  def email_with_unicode_in_header do
    %Mailman.Email{
      subject: "Hello Mailman!",
      from: "Some Emoji – 👍 <mailman@elixir.com>",
      reply_to: "Some more Emoji – 🔥 <reply@example.com>",
      to: ["Another Emoji – 💕 <ciemniewski.kamil@gmail.com>"],
      cc: ["Another Emoji! – 🎁 <testy2#tester1234.com>", "abcd@defd.com"],
      bcc: ["Yet another emoji! – 🌹 <1234@wsd.com>", "Just ASCII <test@example.com>"],
      text: "Yo, here's one more emoji: 🆕",
      html: "<div>Yo, here's one more emoji: 🆕</div>",
    }
  end

  test "should encode email parts properly" do
    email_with_unicode_in_header = email_with_unicode_in_header()
    rendered_email = Mailman.Render.render(email_with_unicode_in_header, %Mailman.EexComposeConfig{})

    # Un-comment this to investigate problems with header encodings
    # IO.inspect(rendered_email)

    assert true
  end
end
