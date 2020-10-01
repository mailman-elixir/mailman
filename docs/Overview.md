# Overview

Mailman lets you send email from your Elixir app.

Mailman supports multi-part (plaintext and HTML) messages, inline images, attachments, custom headers, and more.


## Which email library should I choose? Mailman vs. Bamboo vs. Swoosh
The Elixir ecosystem now offers a number of email libraries to choose from.

Mailman has been around the longest. As an Elixir wrapper around the battle-tested [gen_smtp](https://github.com/vagabond/gen_smtp) client, it is designed primarily with SMTP power users in mind. If you are interfacing directly with an SMTP relay, Mailman is for you.

If you instead work with a commercial email service like SendGrid or Mailgun, consider libraries like [Bamboo](https://github.com/thoughtbot/bamboo) and [Swoosh](https://github.com/swoosh/swoosh), which come with clients for these services. Note that both of these libraries offer SMTP adapters as well.

## Simple example
Emails are sent using the `Mailman.deliver` function. All you need is the email itself and a `%Mailman.Context{}` configuration struct:

```elixir
context = %Mailman.Context{
  config: %Mailman.SmtpConfig{
      relay: "yourtdomain.com",
      username: "userkey-here",
      password: "passkey-here",
      port: 25,
      tls: :always,
      auth: :always,
  },
  composer: %Mailman.EexComposeConfig{}
}

email = %Mailman.Email{
  subject: "Hello Mailman!",
  from: "mailman@elixir.com",
  to: ["test1@tester123456.com"],
  cc: ["test2@tester1234.com", "abcd@defd.com"],
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

Mailman.deliver(email, context)
```

