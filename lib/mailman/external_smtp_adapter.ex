defmodule Mailman.ExternalSmtpAdapter do
  @moduledoc "Adapter for sending email via external SMTP server"

  @doc "Delivers an email based on specified config"
  def deliver(config, email, message) do
    relay_config = [
      relay: config.relay,
      username: config.username,
      password: config.password,
      port: config.port,
      ssl: config.ssl,
      tls: config.tls,
      auth: config.auth
    ]

    from_envelope_address = email.from
    to_envelope_address = email.to

    ret =
      :gen_smtp_client.send_blocking(
        {
          from_envelope_address,
          to_envelope_address,
          message
        },
        relay_config
      )

    case ret do
      {:error, _, _} -> ret
      {:error, _} -> ret
      _ -> {:ok, message}
    end
  end
end
