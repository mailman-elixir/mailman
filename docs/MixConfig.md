# Configuration tips

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

## Defining Mailer modules
It can be helpful to encapsulate email-related functionality in a separate *Mailer* module. Such a Mailer may also be a good place to check whether delivery was successful, to store delivery records in a database, etc.:

```elixir
defmodule MyApp.Mailer do
  def deliver(email) do
    Mailman.deliver(email, config())
  end

  def config do
    %Mailman.Context{
      config: %Mailman.SmtpConfig{
        relay: "yourdomain.com",
        username: "userkey-here",
        password: "passkey-here",
        port: 25,
        tls: :always,
        auth: :always,
      },
      composer: %Mailman.EexComposeConfig{}
    }
  end

  # ... other functions related to email logistics
end
```

You can then use `MyApp.Mailer.deliver` anywhere in your application:
```elixir
def some_function do
  email = %Mailman.Email{
    subject: "Hello Mailman!",
    from: "mailman@elixir.com",
    to: ["test@example.com"],
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
   
  MyApp.Mailer.deliver(email)
end
```
