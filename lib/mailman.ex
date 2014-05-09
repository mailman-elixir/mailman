defmodule Mailman do

  defprotocol Adapter do
    def deliver(context, email, message)
  end

  defprotocol Composer do
    def compile_part(config, mode, email)
  end

  @doc "Deliver given email"
  def deliver(email, context) do
    message = Mailman.Emails.render(email, context.composer)
    Adapter.deliver(context.config, email, message)
  end

  def start_smtp do
    :gen_smtp_server.start(:smtp_server_example, [[port: 1465]])
  end
end
