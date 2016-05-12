defmodule Mailman.ExternalSmtpAdapter do
  @moduledoc "Adapter for sending email via external SMTP server"

  @default_validator ~r/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})/

  @doc "Delivers an email based on specified config"
  def deliver(config, email, message, opts \\ []) do
    relay_config = [
      relay: config.relay,
      username: config.username,
      password: config.password,
      port: config.port,
      ssl: config.ssl,
      tls: config.tls,
      auth: config.auth
      ]
    validator = if opts[:validator] == nil do
      @default_validator
    else
      opts[:validator]
    end

    from_envelope_address = envelope_email(email.from, validator)
    to_envelope_address   = Enum.map(email.to, &(envelope_email(&1, validator)))
    ret = :gen_smtp_client.send_blocking {
      from_envelope_address,
      to_envelope_address,
      message
    }, relay_config
    case ret do
      { :error, _, _ } -> ret
      { :error, _ } -> ret
      _ -> { :ok, message }
    end
  end


  defp envelope_email(email_address, validator) do
    pure_from = Regex.run(~r/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})/, email_address)
      |> Enum.at(1)
  end

end
