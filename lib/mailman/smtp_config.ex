defmodule Mailman.SmtpConfig do
  @moduledoc """
  A config struct for external SMTP server adapter.
  """

  @derive {Inspect, except: [:password]}
  defstruct relay: "",
    username: "",
    password: "",
    port: 1111,
    ssl: false,
    tls: :never,
    hostname: nil,
    auth: :always

end

defimpl Mailman.Adapter, for: Mailman.SmtpConfig do
  def deliver(config, email, message) do
    Mailman.ExternalSmtpAdapter.deliver(config, email, message)
  end
end
