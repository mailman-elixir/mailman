# Configuration using Mix.Config

You can pass context configuration to Mailman using `Mix.Config`. If you don't set a `config` field value in `Mailman.Context{}` struct, or if you set it to `nil`, Mailman expects to read the value from your `config.exs` file (or a file imported by it).

Here is an example config file snippet for Mailman:

```elixir
config :mailman,
  relay: "localhost",
  port: 1025,
  auth: :never
```

You can also explicitly set the adapter. In this case, all the other options will be used when creating the adapter config:

```elixir
config :mailman,
  adapter: MyApp.MyMailAdapter, # or e.g. Mailman.LocalSmtpAdapter
  port: 1025,
  custom_param: "something"
```
