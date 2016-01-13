defmodule Mailman do

  defprotocol Adapter do
    @moduledoc "Protocol for implementing different medium of emails delivery"
    def deliver(context, email, message)
  end

  defprotocol Composer do
    @moduledoc "Protocol for implementing different template systems for compiling email bodies"
    def compile_part(config, mode, email)
  end

  @doc "Delivers given email and returns a Task"
  def deliver(email, context) do
    message = Mailman.Render.render(email, context.composer)
    Adapter.deliver(context.config, email, message)
  end
end
