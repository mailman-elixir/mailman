defmodule Mailman.ExternalSmtpAdapter do
  @moduledoc """
  Adapter for sending email via external SMTP server.
  """

  @doc """
  Delivers an email based on specified config.
  """
  def deliver(config, email, message) do
    from_envelope_address = email.from
    to_envelope_address = email.to

    ret =
      :gen_smtp_client.send_blocking(
        {
          from_envelope_address,
          to_envelope_address,
          message
        },
        build_relay_config(config)
      )

    case ret do
      {:error, _, _} -> ret
      {:error, _} -> ret
      _ -> {:ok, message}
    end
  end

  defp build_relay_config(%{hostname: nil} = config) do
    [
      relay: config.relay,
      username: config.username,
      password: config.password,
      port: config.port,
      ssl: config.ssl,
      tls: config.tls,
      auth: config.auth,
      no_mx_lookups: config.no_mx_lookups
    ]
  end

  defp build_relay_config(config) do
    [
      relay: config.relay,
      username: config.username,
      password: config.password,
      port: config.port,
      ssl: config.ssl,
      tls: config.tls,
      auth: config.auth,
      hostname: config.hostname,
      no_mx_lookups: config.no_mx_lookups
    ]
  end
end
