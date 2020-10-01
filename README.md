# Mailman 👮

![Elixir CI](https://github.com/mailman-elixir/mailman/workflows/Elixir%20CI/badge.svg)
[![Docs](https://img.shields.io/badge/api-docs-green.svg?style=flat)](https://hexdocs.pm/mailman)
[![Hex.pm Version](http://img.shields.io/hexpm/v/mailman.svg?style=flat)](https://hex.pm/packages/mailman)

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


## Simple example 

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
