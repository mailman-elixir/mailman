defmodule Mailman.LocalSmtpAdapter do
  @moduledoc "Adapter for using locally spawned SMTP server"

  @doc "Delivers an email through a locally running process"
  def deliver(config, email, message) do
    Mailman.ExternalSmtpAdapter.deliver external_for(config),
      email, message
  end

  def external_for(config) do
    %Mailman.SmtpConfig{
      relay: "localhost",
      port: config.port,
      auth: :never
    }
  end

end
