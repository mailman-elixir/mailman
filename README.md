# Mailman 👮

[![Elixir CI](https://github.com/mailman-elixir/mailman/actions/workflows/elixir.yml/badge.svg)](https://github.com/mailman-elixir/mailman/actions/workflows/elixir.yml)
[![Module Version](https://img.shields.io/hexpm/v/mailman.svg)](https://hex.pm/packages/mailman)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/mailman/)
[![Total Download](https://img.shields.io/hexpm/dt/mailman.svg)](https://hex.pm/packages/mailman)
[![License](https://img.shields.io/hexpm/l/mailman.svg)](https://github.com/mailman-elixir/mailman/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/mailman-elixir/mailman.svg)](https://github.com/mailman-elixir/mailman/commits/master)

Mailman lets you send email from your Elixir app.

* Plain text or multi-part email (plain text and HTML)
* Inline images in HTML part
* Attachments (with semi-automatic MIME type detection)
* Easy-peasy SMTP config
* Rendering via EEx
* Standard quoted-printable encoding
* Automatic CC and BCC delivery
* Custom headers
* SMTP delivery timestamps

Mailman is a wrapper around the mighty (but rather low-level) [gen_smtp](https://github.com/vagabond/gen_smtp), the popular Erlang SMTP library.

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

## Copyright and License

Copyright (c) 2012 Kamil Ciemniewski

Mailman is released under the MIT License. See the [LICENSE.md](./LICENSE.md) file
for further details.
