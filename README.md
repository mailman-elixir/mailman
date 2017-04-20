## Mailman

Mailman provides a clean way of defining mailers in your Elixir apps. It allows you to send multi-part email messages containing text and html parts. It encodes messages with a proper quoted-printable encoding. It also allows you to send attachments.

To be able to send emails, you only need to provide the SMTP config (like an external SMTP server along with credentials etc.). You also need to define your emails along with text and/or html templates. Mailman uses Eex as a templating language but will likely be extended to provide other choices as well in the future.

### A quick example

```elixir
  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config)
    end

    def config do
      %Mailman.Context{
          config:   %Mailman.LocalSmtpConfig{ port: 1234 },
          composer: %Mailman.EexComposeConfig{}
        }
    end
  end
  
  # somewhere where you start other services in your app:
  Mailman.LocalServer.start 1234 # just pass the port number you want

  # somewhere else:
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
```

And then to actually send an email:
```elixir
  MyApp.Mailer.deliver testing_email
```

### Configuring the mailing context

There are two parts in the configuration data for how Mailman works:

* Composer config
* Adapter config

The first one specifies how emails will be rendered. The second one, how
will they be delivered. 

For now, only the `%Mailman.EexComposeConfig{}` is available for configuring the composer. The library is ready to support any other composer you might want to implement.

There are three adapter configs at the moment: external smtp, local smtp and the testing one. The latter will soon support handling the queue of emails to ease testing of the email sending part of your apps. 

You don't access those adapters directly. Instead, you specify a config of your choice and the library does all the rest for you. The three config options corresponding with adapters are: `%Mailman.LocalSmtpConfig{}`, `%Mailman.SmtpConfig{}` and `%Mailman.TestConfig{}`.

```elixir
%Mailman.Context{
    config:   %Mailman.LocalSmtpConfig{ port: 1234 },
    composer: %Mailman.EexComposeConfig{}
  }
```

Note that to be able to use the local and the test configs, you'll need to start either local SMTP server or the testing service:

```elixir
  Mailman.LocalServer.start(1234)
  # or:
  Mailman.TestServer.start
```

In this example we're setting up the library to use the local SMTP server created along with the app. In order for this to work you still have to create this process:

```elixir
pid = Mailman.LocalServer.start(1234)
```

To be able to send emails using an external SMTP server `SmtpConfig` can be used. Example:

```elixir
%Mailman.Context{
  config: %Mailman.SmtpConfig{
    relay: "yourtdomain.com",
    username: "userkey-here",
    password: "passkey-here",
    port: 25,
    tls: :always,
    auth: :always,
  },
  # ...
}
```

### Configuration using Mix.Config

You can pass context configuration to Mailman using Mix.Config. If you do set `config` field value in `Mailman.Context` struct, or if you set it to `nil`, Mailman expect to read the value from Mix.Config, generally in your `config.exs` file.

Here is an example `mix.exs` file snippet for Mailman:

```elixir
config :mailman,
  relay: "localhost",
  port: 1025,
  auth: :never
```

You can also explicitely set the adapter. In this case, all the other options will be used when creating the adapter config:

```elixir
config :mailman,
  adapter: MyApp.MyMailAdapter,
  port: 1025,
  custom_param: "something"
```

### Defining emails

The email struct is defined as:

```elixir
defstruct subject: "", 
  from: "", 
  to: [], 
  cc: [], 
  bcc: [], 
  attachments: [], # This has to be %Mailman.Attachment{}. More about attachments below
  data: %{}, # This is the context for EEx. You put here data for your <%= %> placeholders
  html: "", # Actual html template
  text: "", # Actual plain template
  delivery: nil # If the message was created through parsing of the delivered email - this holds the 'Date' header
```

### Attaching files

A dedicated struct has been created for describing attachments. In this version, there's a function that takes a binary representing a path to a file that's constructing this struct for you. So you can add attachments to your email definitions like this:

```elixir
attachments: [
  Mailman.Attachment.inline!("test/data/blank.png")
  ],
```

This reads the file from disk, encodes it with base64 and discovers the proper mime-type. Attachments are also properly decoded from existing emails (more on that below).

### Parsing delivered emails

If you have the source of rendered email as a binary, you can use the `Mailman.Email.parse!/1` function to turn it into`%Mailman.Email{}`.

Here's an example from the test suite:

```elixir
{:ok, message} = MyApp.Mailer.deliver(email_with_attachments)
email = Mailman.Email.parse! message
```

At this point, if the source contains the 'Date' header (meaning that it was put through a mailing system) — it will have the 'delivery' field non-empty.

### Inspecting deliveries when testing

When you use the TestServer you can take a look at the deliveries with:

```elixir
  Mailman.TestServer.deliveries
```

Also, if you want to clear this list:

```elixir
  Mailman.TestServer.clear_deliveries
```

## Using with Hex

There's one gotcha currently when using the package with Hex. Because of the dependency on the eiconv library and it's absence in the Hex database, you have to specify it as a dependency on your own in your mix.exs

As an example:

```elixir
defp deps do
  [
    {:mailman, "~> 0.3.0"},
    {:eiconv, github: "zotonic/eiconv"}
  ]
end
```

This way you'll be able to use the parse! function to parse delivered emails.

## TODOs

- [x] A SMTP config that would use internal server/process coming with :gen_smtp
- [x] A testing config that stores deliveries
- [x] Ability to send attachments
- [x] Ability to provide CC and BCC
- [ ] Unit testing (somewhat in progress)

## Contributors

* Josh Adams ([https://github.com/knewter]())
* Dan McClain ([https://github.com/danmcclain]())
* Holger Amann ([https://github.com/hamann]())
* Low Kian Seong ([https://github.com/lowks]())
* Stian Håklev ([https://github.com/houshuang]())
* Dejan Štrbac ([https://github.com/dejanstrbac]())
* Benjamin Nørgaard ([https://github.com/blacksails]())
* JustMikey ([https://github.com/JustMikey]())
* swerter ([https://github.com/swerter]())
* Richard Leland ([https://github.com/richleland]())
* Max Neuvians ([https://github.com/maxneuvians]())
* Jeff Weiss ([https://github.com/jeffweiss]())
* Mickaël Rémond ([https://github.com/mremond]())
* Anthony Graham ([https://github.com/trinode])
* Gerry Shaw ([https://github.com/gshaw])
* Martin Maillard ([https://github.com/martinmaillard])
* Keitaroh Kobayashi ([https://github.com/keichan34])
* Arunvel Sriram ([https://github.com/arunvelsriram])
* Martin Chabot ([https://github.com/martinos])
* Mike Martinson ([https://github.com/mmartinson])
* Wojciech Stachowski ([https://github.com/Antiavanti])
* Uģis Ozols ([https://github.com/ugisozols])
