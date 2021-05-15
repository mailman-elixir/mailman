# Rendering using EEx

You are free to pass any plaintext and HTML strings to the `:html` and `:text` fields of the `%Mailman.Email{}` struct.

However, for any serious emailing purposes, you will want to use a templating engine to handle the find-and-replace effort of personalized, event-triggered emails, as well as wrap your email bodies in a responsive, battle-tested HTML template (like [Cerberus](https://github.com/TedGoas/Cerberus), [Pine](https://thememountain.github.io/pine/) or [Foundation](http://foundation.zurb.com/emails.html)). To that end, what better templating engine than Elixir's very own [EEx](https://hexdocs.pm/phoenix/templates.html)!

There are three ways to use EEx with Mailman:

## Using the `data` field
You can use EEx strings for the `:text` and `:html` values of the email struct, and pass a Keyword list of values to the `:data` field like so:

```elixir
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
```

## Using EEx templates
If your email bodies are long, you may prefer to keep them in separate files, in which case you need to tell Mailman where to find them.

You can do so using the fields in the `%Mailman.EexComposeConfig{}` struct:

```elixir
%Mailman.Context{
  composer: %Mailman.EexComposeConfig{
    root_path: "",
    assets_path: "", 
    text_file: false,
    html_file: false,
    text_file_path: "",
    html_file_path: ""
  },
  config:   %Mailman.SmtpConfig{...},
}
```

If e.g. `text_file == true`, then Mailman will assume that your emails' `:text` value wil be the filename of your Eex template in the `text_file_path` directory (instead of a raw, plaintext, email body string).

For now, only the `%Mailman.EexComposeConfig{}` is available for configuring the existing EexComposer (although the library is happy to instead use any other composer module you might want to implement).

## Using Phoenix views with templates
If you are already using Phoenix, you may prefer using your existing `template/`
and `views/` folders and rendering the EEx through Phoenix yourself:

```elixir
data = %{foo: "bar"}
rendered_html = Phoenix.View.render_to_string(App.YourEmailView, "your_email_template.html", data)
```

You can then use the rendered email bodies directly:

```elixir
email = %Mailman.Email{
  ...
  html: rendered_html,
  ...
}
```

