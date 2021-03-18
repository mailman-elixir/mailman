# Checking for successful delivery
Mailman's `deliver` function will return `{:ok, raw_delivered_message}`, which contains this information. You can turn this raw string back into a `%Mailman.Email{}` struct using `Mailman.Email.parse!`:

```elixir
{:ok, message} = MyApp.Mailer.deliver(email_with_attachments)
parsed_email = Mailman.Email.parse!(message)
delivered_date = parsed_email.delivery
```

At this point, if the `deliver` function added the `Date` header (meaning that it was accepted by the SMTP server) — then its value should show up in the `delivery` field.

