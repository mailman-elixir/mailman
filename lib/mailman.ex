defmodule Mailman do

  defprotocol Adapter do
    def deliver(context, email, message)
  end

  defprotocol Composer do
    def compile_part(config, mode, email)
    def compile_part(config, mode, email, body)
  end

  @doc "Delivers given email and returns a Task"
  def deliver(email, context) do
    message = Mailman.Render.render(email, context.composer)
    Adapter.deliver(context.config, email, message)
  end

  def start_smtp do
    :gen_smtp_server.start(:smtp_server_example, [[port: 1465]])
  end
end
