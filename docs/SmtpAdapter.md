# SMTP adapter config

The `%Mailman.SmtpConfig{}` struct accepts the following values:

```elixir
%Mailman.SmtpConfig{
  relay: "yourdomain.com",
  username: "userkey-here",
  password: "passkey-here",
  port: 25,      
  tls: :always,  # :never or :always or :if_available
  auth: :always, # :never or :always
  ssl: true,     # true or false
},
```

