# Local and test adapter config

In addition to the `%Mailman.SmtpConfig{}` struct, your configuration also accepts:

* `%Mailman.LocalSmtpConfig{}`, for sending on your local machine,
* `%Mailman.TestConfig{}`, for testing.

The local config struct looks like 
```elixir
%Mailman.LocalSmtpConfig{
  port: 2525 
}
```

And the test config struct looks like
```elixir
%Mailman.TestConfig{
  store_deliveries: true
}
```

Note that in order to be able to use the local and the test configs, you'll need to start either local SMTP server or the testing service, wherever you start other services in your app:

```elixir
Mailman.LocalServer.start(1234)
# or:
Mailman.TestServer.start
```
