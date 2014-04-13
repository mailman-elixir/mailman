**Warning** This is an alpha software — meant to be an early proposal for providing a high level email sending solution for the Elixir language.

## Mailman

Mailman provides a clean way of defining mailers in your Elixir applications. It allows you to send multi-part email messages containing text and html parts. It encodes messages with a proper quoted-printable encoding.

To be able to send emails, you only need to provide a SMTP config (like an external SMTP server along with credentials etc.). You also need to define your emails along with text and/or html templates. Mailman uses Eex as a templating language but will likely be extended to provide other choices as well in the future.

### A quick example

```elixir
# First, implement the Mailer protocol for Email.
# The default implementation raises an error asking
# you to implement it yourself.
#
# You only need to implement the config/1 function.
# It should return a config record. There are two 
# config modes to choose from: SmtpConfig and TestConfig.
#
# (we're using here the fact that implementations can be
# redefined)
defimpl Mailman.Mailer, for: Mailman.Email do
  def config(email) do
    Mailman.SmtpConfig[
      relay: "smtp.gmail.com",
      username: "yourgmailaccount@gmail.com",
      password: "Yourpassword",
      port: 465,
      ssl: true
    ]
  end
end

# Next, tell the library where are templates for your
# emails. In the future the Composer protocol will likely
# allow you to choose from more than just Eex templating
# library.
defimpl Mailman.Composer, for: Mailman.Email do
  def root_path(email) do
    "app/views"
  end
end

# To compose email, just provide an Mailman.Email 
def hello_email(user) do
  Mailman.Email[
    name: "hello",
    subject: "Hello #{user.name}!",
    from: "info@yourcoolstartup.com",
    to: [ user.email ],
    data: [
      name: user.name
      ]
    ]
end
```

app/views/hello.text.eex:
```elixir
Hello! <%= name %>!
```

And then to actually send an email:
```elixir
# Note that for now deliver/1 is blocking. This will likely
# change and we'll have two functions for delivery:
# deliver/1 and deliver_blocking/1
hello_email(user) |> Mailman.deliver
```

### A note about records in examples

Be aware that records are getting deprecated with upcoming 
Elixir 0.13. Very soon, all those definitions will get upgraded
to use structs instead.

### Configuring SMTP connection

The configuration record is defined as:

```elixir
  defrecord SmtpConfig, 
    relay: "", 
    username: "", 
    password: "", 
    port: 1111, 
    ssl: false, 
    tls: :never, 
    auth: :always
```

All those options correspond with ones defined
in the **gen_smtp** library. You can find out more
about them here: https://github.com/Vagabond/gen_smtp

### Defining emails

The email record is defined as:

```elixir
  defrecord Email, 
    name: "", # this has to be the same as your template name on the disk
    subject: "",
    from: "", 
    to: [], 
    cc: [], # not in use yet
    bcc: [], # not in use yet
    attachments: [], # not in use yet
    data: [], # context data for Eex templates
    meta: [] # means of distinguishing between email types in protocol implementations
```

A quick word about *meta* field: it's just a proposal 
of having some way of returning e. g. different configs
for different emails.

Example:

```elixir
defimpl Mailman.Mailer, for: Mailman.Email do
  def config(Mailman.Email[meta: [mode: :mass]]) do
    Mailman.SmtpConfig[
      relay: "smtp.somemassdeliverytool.com",
      username: "youraccount@somemassdeliverytool.com",
      password: "Yourpassword"
    ]
  end
  
  def config(email) do
    Mailman.SmtpConfig[
      relay: "smtp.gmail.com",
      username: "yourgmailaccount@gmail.com",
      password: "Yourpassword",
      port: 465,
      ssl: true
    ]
  end
end

def newsletter_email(user) do
  Mailman.Email[
    name: "newsletter",
    subject: "Hello #{user.name}!",
    from: "info@yourcoolstartup.com",
    to: [ user.email ],
    data: [
      name: user.name
      ]
    ],
    meta: [
      mode: :mass
    ]
end
```

Note that Mailman will look into the directory you've 
provided for templates and will infer whether it should use 
just plain or plain+html parts. Your **html** part templates
have to have an ".html.eex" extesnion while plain ones ".text.eex".

## TODOs

* Unit testing
* A SMTP config that would use internal server/process coming with :gen_smtp
* API cleanup?
* Ability to send attachments
* Ability to provide CC and BCC
