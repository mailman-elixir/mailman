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
      pure_from = Regex.run(~r/<((\w*\.?)*@(\w*\.?)*)>/, email.from) |> Enum.at(1)
      pure_to   = Regex.run(~r/<((\w*\.?)*@(\w*\.?)*)>/, email.to) |> Enum.at(1)
      ret = :gen_smtp_client.send_blocking {
        pure_from,
        pure_to,
        message
      }, relay_config
      case ret do
        { :error, _ } -> ret
        _ -> { :ok, message }
      end
  end

end

