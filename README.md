## Mailman 👮

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

## TODOs

- [ ] Send multiple emails using the same connection [gen_smtp PR](https://github.com/Vagabond/gen_smtp/pull/117)
- [ ] Throttling/rate limiting of email deliveries


