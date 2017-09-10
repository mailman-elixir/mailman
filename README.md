## Mailman 👮

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

### A quick example

```elixir
  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config())
    end

    def config do
      %Mailman.Context{
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
    end
  end

  # somewhere else:
  def test_email do
    email = %Mailman.Email{
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      to: ["testy@tester123456.com"],
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
     
    MyApp.Mailer.deliver(email)
  end
```

As you can see, all you need is a `%Mailman.Email{}` struct containing your email and a `%Mailman.Context{}` with the configuration data.

### Rendering email bodies
You are free to pass any plaintext and HTML strings to the `:html` and `:text` fields of the `Email` struct.

However, for any serious emailing purposes, you will want to use a templating engine to handle the find-and-replace effort of personalized, event-triggered emails, as well as wrap your email bodies in a responsive, battle-tested HTML template (like [Cerberus](https://github.com/TedGoas/Cerberus), [Pine](https://thememountain.github.io/pine/) or [Foundation](http://foundation.zurb.com/emails.html)). To that end, what better templating engine than Elixir's very own [EEx](https://hexdocs.pm/phoenix/templates.html)!

There are multiple ways to use EEx with Mailman:

1. **The basic way:** You can use eex strings for the `:text` and `:html` values, and pass data in
   via `:data` (as in the example);
2. **Slightly more work but much less clutter:** You can use template file names for the `:text` and `:html` values, and
   tell Mailman where to find them (see below);
3. **Use Phoenix instead:** If you are already using Phoenix, you may prefer using your existing
   `template/` and `views/` folders and calling EEx through Phoenix like so:
```elixir
rendered_html = Phoenix.View.render_to_string(App.YourEmailView, "your_email_template.html", %{foo: "bar"})
```

### Configuring the mailing context

Mailman is configured using a single `%Mailman.Context{}` struct containing
`composer` and `config` data.

```elixir
%Mailman.Context{
  composer: %Mailman.EexComposeConfig{...}
  config:   %Mailman.SmtpConfig{...},
}
```

#### Composer config (rendering your emails)
For now, only the `%Mailman.EexComposeConfig{}` is available for configuring the existing `EexComposer` (although the library is happy to instead use any other composer module you might want to implement). You can pre-configure the `EexComposer` with the following options:
```elixir
%Mailman.EexComposeConfig{
  root_path: "",
  assets_path: "", 
  text_file: false,
  html_file: false,
  text_file_path: "",
  html_file_path: ""
}
```
If e.g. `text_file == true`, then Mailman will assume that your emails' `:text` value wil be the filename of your eex template in the `text_file_path` directory (instead of a raw, plaintext, email body string).

#### Adapter config – how to send the rendered email
You can set your context's `:config` to any of the following three structs:

* `%Mailman.SmtpConfig{}` for sending from an external server,
* `%Mailman.LocalSmtpConfig{}` for sending on your local machine,
* `%Mailman.TestConfig{}` for testing.

Mailman's external, local or testing adapter will handle your email accordingly.

The external config struct takes the following options:
```elixir
%Mailman.SmtpConfig{
  relay: "yourtdomain.com",
  username: "userkey-here",
  password: "passkey-here",
  port: 25,
  tls: :always,  # or :never
  auth: :always, # or :never
},
```

The local config struct looks like 
```elixir
%Mailman.LocalSmtpConfig{
  port: 2525 
}
```
The test config struct looks like
```elixir
%Mailman.TestConfig{
  store_deliveries: true
}
```
Note that to be able to use the local and the test configs, you'll need to start either local SMTP server or the testing service, wherever you start other services in your app:

```elixir
Mailman.LocalServer.start(1234)
# or:
Mailman.TestServer.start
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

You can pass context configuration to Mailman using `Mix.Config`. If you don't set a `config` field value in `Mailman.Context{}` struct, or if you set it to `nil`, Mailman expect to read the value from your `config.exs` file (or a file imported by it).

Here is an example config file snippet for Mailman:

```elixir
config :mailman,
  relay: "localhost",
  port: 1025,
  auth: :never
```

You can also explicitely set the adapter. In this case, all the other options will be used when creating the adapter config:

```elixir
config :mailman,
  adapter: MyApp.MyMailAdapter, # or e.g. Mailman.LocalSmtpAdapter
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

### CC and BCC
To instruct Mailman to actually send copies of your email to the listed CC and BCC recipients, use `Mailman.deliver(email, config, :send_cc_and_bcc)`. This, unfortunately, goes against the behaviour you are probably used to from end-user email apps, but reflects how SMTP servers work.

The `:cc`/`:bcc` fields only add corresponding *header lines* to the rendered email source. They do not, by themselves, magically effect delivery of actual copies to those recipients – they only change what's written on the envelope, so to speak. By default, Mailman will render the email struct and deliver it to the SMTP server only once, with a single set of recipients – those in the `:to` list. The `:send_cc_and_bcc` flag is a shortcut that will cause delivery of multiple emails at once. It returns a list of Tasks you can process.

If you need even more fine-grained control over CC/BCC mechanics, you will be best served by the lower-level `gen_smtp` functions, e.g.

```elixir
email_tuple = {
  from_address,
  [to_address],
  rendered_message,
}
result = :gen_smtp_client.send_blocking(email_tuple, %Mailman.SmtpConfig{...})
```

### Attachments

Mailman makes it easy to attach files, whether they're on your hard drive or on the internet.

The standard way to create an attachment is to use the `attach!` function:

```elixir
Mailman.Attachment.attach!(file_path_or_url, file_name \\ nil, mime_tuple \\ nil)
```
Use it when creating your email:
```elixir
attachments: [
  Mailman.Attachment.attach!("test/data/blank.png")
],
```

`file_path_or_url` can be an absolute file path, or one relative to the root of your project. You can also give it a URL, in which case Mailman will download the file for you before wrapping it in the Attachment struct.

`file_name` (optional) allows you to change the attachment's file name in the email.

`mime_tuple` (optional) allows you to set the MIME type of your file. This is rarely necessary, as Mailman can often infer this information from your file's extension and an included list of common MIME types. However, if that fails, you may specify the MIME type and subtype in a 2-tuple, e.g. `{"application", "vnd.openxmlformats-officedocument.wordprocessingml.document"}` for a docx file.

Note that the `attach!` option will throw an exception if it cannot open the file; use the `attach` function if you want to match on `{:ok, attachment}`, or `{:err, message}` instead.

#### Inline images
Emails can take inline content – typically, this is used for inlined images in the HTML part of the email. To add an inline image, first attach the file using the `inline!` function (instead of `attach!` – the arguments are the same). Then reference the image in your HTML body as follows:
```html
<img alt="foobar" src="cid:<%= URI.encode("your_filename.jpg") %>@mailman.attachment" />
```
The `cid:` prefix tells the email client that what follows is the `Content-ID` of an inlined attachment. The `@mailman.attachment` suffix is a meaningless dummy string (RFC 2392 requires Content IDs to look like email addresses).

### Adding extra headers

The `deliver` function takes an optional third parameter (or fourth, if you are using `:send_cc_and_bcc`) for that purpose:
```elixir
Mailman.deliver(your_email_struct, your_config, [{"X-Test-Header", "123"}])
```

### Was the email delivered successfully?
Mailman's `deliver` function will return `{:ok, raw_delivered_message}`, which contains this information. You can turn this raw string back into a `%Mailman.Email{}` struct using `Mailman.Email.parse!`:

```elixir
{:ok, message} = MyApp.Mailer.deliver(email_with_attachments)
parsed_email = Mailman.Email.parse!(message)
delivered_date = parsed_email.delivery
```

At this point, if the `deliver` function added the `Date` header (meaning that it was accepted by the SMTP server) — then its value should show up in the `delivery` field.

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
    {:mailman, "~> 0.4.0"},
    {:eiconv, github: "zotonic/eiconv"}
  ]
end
```

This way you'll be able to use the parse! function to parse delivered emails.

## TODOs

- [ ] Send multiple emails using the same connection [gen_smtp PR](https://github.com/Vagabond/gen_smtp/pull/117)
- [ ] Unit testing (somewhat in progress)

## Contributors

* Josh Adams ([[[https://github.com/knewter]())
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
* Anthony Graham ([https://github.com/trinode]())
* Gerry Shaw ([https://github.com/gshaw]())
* Martin Maillard ([https://github.com/martinmaillard]())
* Keitaroh Kobayashi ([https://github.com/keichan34]())
* Arunvel Sriram ([https://github.com/arunvelsriram]())
* Martin Chabot ([https://github.com/martinos]())
* Mike Martinson ([https://github.com/mmartinson]())
* Wojciech Stachowski ([https://github.com/Antiavanti]())
* Uģis Ozols ([https://github.com/ugisozols]())
* Martin Schurig ([https://github.com/schurig]())
* Mathieu Rhéaume ([https://github.com/ddrmanxbxfr]())
* Sebastian Kosch ([https://github.com/skosch]())
