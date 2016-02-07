defmodule Mailman.LocalSmtpConfig do
  @moduledoc "Configuration struct for the locally spawned SMTP server"

  defstruct port: 2525
end

defimpl Mailman.Adapter, for: Mailman.LocalSmtpConfig do
  def deliver(config, email, message) do
    Mailman.LocalSmtpAdapter.deliver(config, email, message)
  end
end
