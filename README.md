## Mailman

Mailman provides a clean way of defining mailers in your Elixir applications. It allows you to send multi-part email messages containing text and html parts. It encodes messages with a proper quoted-printable encoding.

To be able to send emails, you only need to provide a SMTP config (like an external SMTP server along with credentials etc.). You also need to define your emails along with text and/or html templates. Mailman uses Eex as a templating language but will likely be extended to provide other choices as well in the future.

### A quick example

```elixir
  defmodule MyApp.Mailer do
    def deliver(email) do
      Mailman.deliver(email, config)
    end

    def config do
      %Mailman.Context{
          config: %Mailman.TestConfig{},
          composer: %Mailman.EexComposeConfig{
            root_path: "test/views"
            }
        }
    end
  end

  # somewhere else:
  def testing_email do
    %Mailman.Email{
      name: "hello",
      subject: "Hello Mailman!",
      from: "mailman@elixir.com",
      to: [ "testy@tester123456.com" ],
      data: [
        name: "Yo"
        ]
      }
  end
```

app/views/hello.text.eex:
```elixir
Hello! <%= name %>!
```

And then to actually send an email:
```elixir
# Note that for now deliver/1 is blocking. In the future it will return a Task
MyApp.Mailer.deliver testing_email
```

### Configuring the mailing context

There are two parts in the configuration data for how Mailman works:

* Composer config
* Adapter config

The first one specifies how emails will be rendered. The second one, how
will they be delivered. 

All those options correspond with ones defined
in the **gen_smtp** library. You can find out more
about them here: https://github.com/Vagabond/gen_smtp

```elixir
%Mailman.Context{
    composer: %Mailman.EexComposeConfig{
      root_path: "test/views"
      },
    config: %Mailman.SmtpConfig{
      relay: "smtp.yourdomain.com",
      username: "youruser",
      password: "password",
      port: 1234,
      ssl: true
      }
  }
```

### Defining emails

The email struct is defined as:

```elixir
defmodule Mailman.Email do
  defstruct name: "", # this has to be the same as your template name on the disk
    subject: "", 
    from: "", 
    to: [], 
    cc: [], # not in use yet
    bcc: [], # not in use yet
    attachments: [], # not in use yet
    data: %{} # context data for Eex templates

end
```

Example:

```elixir
# The Mailman.deliver/2 takes an email and a context. Strongly advices is to put
# it inside your own deliver method:
defmodule MyApp.Mailer do
  def deliver(email) do
    Mailman.deliver(email, config)
  end

  def config do
    %Mailman.Context{
        composer: %Mailman.EexComposeConfig{
          root_path: "test/views"
          },
        config: %Mailman.SmtpConfig{
          relay: "smtp.yourdomain.com",
          username: "youruser",
          password: "password",
          port: 1234,
          ssl: true
          }
      }
  end
end

def newsletter_email(user) do
  %Mailman.Email{
    name: "hello",
    subject: "Hello Mailman!",
    from: "mailman@elixir.com",
    to: [ "testy@tester123456.com" ],
    data: [
      name: "Yo"
      ]
    }
end
```

Note that Mailman will look into the directory you've 
provided for templates and will infer whether it should use 
just plain or plain+html parts. Your **html** part templates
have to have an ".html.eex" extesnion while plain ones ".text.eex".

## TODOs

* Unit testing
* A SMTP config that would use internal server/process coming with :gen_smtp
* Ability to send attachments
* Ability to provide CC and BCC
