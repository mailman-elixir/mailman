**Warning** This is an alpha software — meant to be an early proposal for providing a high level email sending solution for the Elixir language.

# Mailman

Mailman provides a clean way of defining mailers in your Elixir applications. It allows you to send multi-part email messages containing text and html parts. It encodes messages with a proper **quoted-printable** encoding.

To be able to send emails, you only need to choose and configure an adapter (like an external SMTP server along with credentials etc.). You also need to define your emails along with text and/or html templates. Mailman uses Eex as a templating language but will likely be extended to provide other choices as well in the future. 

Example:
```elixir
defmodule MyApp do
  defmodule EmailsComposer do
    def templates_root do
      "app/views/emails"
    end
  end

  defmodule RealAdapter do
    use Mailman.ExternalSmtpAdapter

    config do
      relay "smtp.gmail.com"
      username "youraddress@gmail.com"
      password "Yourpassword"
      port 465
      ssl true
    end
  end

  defmodule Mailer do
    use Mailman.Mailer, adapter: RealAdapter
  end

  defmodule AccountEmails do
    use Mailman.Emails, composer: EmailsComposer

    default_from "tester@elixir.com"

    compose :welcome, user do
      subject "Welcome"
      to [ user.email ]
      data :name, user.name
    end
  end
end
```
And in app/views/emails/welcome.html.eex:
```elixir
Hello <%= name %>!
```

## Introduction

* Envelopes — definitions of emails ready to be sent
* Email modules — containing definitions of emails that can take arguments in order to configure them
* Composers — containing configuration of the process of turning email definitions into valid email messages ready to be sent
* Adapters — defining the process of sending emails. By default, **mailman** provides two adapters: **ExternalSmtpAdapter** and **TestingAdapter**
* Mailers — modules building upon adapters for sending email messages

## Envelope

An envelope is a single definition of an email message. It contains body parts as well as the headers (like *Subject*, *From*, *To* etc).

## Email modules

An email module contains one or more definition of an **envelope**. A definition like this:
```elixir
defmodule ErrorNotifiersEmails do
  use Mailman.Emails, composer: EmailsComposer

  default_from "tester@elixir.com"

  compose :general_error_notifier, error do
    subject „[Error]  - #{error.name}”
    to [ „developers@yourapp.com” ]
    data :error, error
  end
end
```

Provides a **get** function responding to a :general_error_notifier as a first argument wit ha proper envelope (provided that a error value is provided as second too):
```elixir
ErrorNotifiersEmails.get :general_error_notifier, error # Mailman.Envelope
```
## Composers

Composers are configuration holders for the presentation layer of an envelope. The **mailman** library is meant to be used within **any** kind of application and alongside of **any** application framework. Because of this, it cannot assume anything when it comes to reading template definitions from the disc.

As of now - it only allows you specify this path. In the future, it will likely allow you to configure the presentation layer more (maybe choosing a templating language?)
```elixir
defmodule EmailsComposer do
  def templates_root do
    "app/views/emails"
  end
end
```
This tells Mailman where to look for template definitions.

## Adapters

Adapters implement the functionality behind the process of sending envelopes as emails. There are two providers in the library already: **ExternalSmtpAdapter** and **TestingAdapter**

### ExternalSmtpAdapter

This adapter allows you to use an external SMTP server as means of sending emails to real mailboxes:
```elixir
defmodule RealAdapter do
  use Mailman.ExternalSmtpAdapter

  config do
    relay "smtp.gmail.com"
    username "youraddress@gmail.com"
    password "Yourpassword"
    port 465
    ssl true
  end
end
```
You’re supposed to **use** the Mailman.ExternalSmtpAdapter module and use **config** macro to specify its configuration variables.

### TestingAdapter

This adapter is provided for your **testing** environments. It renders envelopes into emails just as a **ExternalSmtpAdapter** does, but it doesn’t send it anywhere. You can then examine the contents of those emails as the **deliver** method returns then in a tuple. 
```elixir
defmodule DummyAdapter do
  use Mailman.TestingAdapter
end
```
## Mailers

They are means of sending rendered email messages. It provides a **send** function that takes a rendered envelope. The return value of this function contains a tuple 
```elixir
{ :ok, messages }
```
Or:
```elixir
{ :error, reasons }
```
## Sending emails

To send an email, you first need to **get** it from an emails module providing the context data like e.g.:
```elixir
case ErrorNotifiersEmails.get(:general_error_notifier, error) of
  { :ok, envelope } -> 
    case Mailer.send envelope of
       { :ok, rendered_emails } -> … # sent properly
       { :error, reasons } -> … # e. g. smtp error….
    end 
  { :error, reasons } -> …. # most probably a development time error here
end
```
You could of course do this without checking for errors in one line (not recommended):
```elixir
ErrorNotifiersEmails.get(:general_error_notifier, error) |> elem(1) |> Mailer.send
```
## TODOs

* Much more unit testing in place
* An InternalSmtpAdapter using an SMTP server/process coming with :gen_smtp
* API cleanup?
* Ability to send attachments
