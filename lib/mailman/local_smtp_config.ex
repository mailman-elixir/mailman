defmodule Mailman.LocalSmtpConfig do
  defstruct port: 2525
end

defimpl Mailman.Adapter, for: Mailman.LocalSmtpConfig do
  def deliver(config, email, message) do
    Mailman.LocalSmtpAdapter.deliver(config, email, message)
  end
end
