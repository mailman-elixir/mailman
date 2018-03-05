defmodule Mailman do

  defprotocol Adapter do
    @moduledoc "Protocol for implementing different medium of emails delivery"
    def deliver(context, email, message)
  end

  defprotocol Composer do
    @moduledoc "Protocol for implementing different template systems for compiling email bodies"
    def compile_part(config, mode, email)
  end

  @doc "Delivers given email to all addresses and returns a list of Tasks"
  def deliver(email, context, :send_cc_and_bcc, extra_headers) do
    bcc_list = email.bcc
    cleaned_email = %Mailman.Email{email | bcc: []}
    config = Mailman.Context.get_config(context)
    message = Mailman.Render.render(cleaned_email, context.composer, extra_headers)

    to_task = [Adapter.deliver(config, email, message)]

    cc_tasks = email.cc |> Enum.map(fn(address) ->  
      cc_envelope = %Mailman.Email{email | to: [address]}
      Adapter.deliver(config, cc_envelope, message)
    end)

    bcc_tasks = bcc_list |> Enum.map(fn(address) ->  
      bcc_envelope = %Mailman.Email{email | to: [address]}
      bcc_message = %Mailman.Email{email | bcc: [address]}
      message = Mailman.Render.render(bcc_message, context.composer)
      Adapter.deliver(config, bcc_envelope, message)
    end)

    to_task ++ cc_tasks ++ bcc_tasks
  end

  def deliver(email, context, :send_cc_and_bcc) do
    deliver(email, context, :send_cc_and_bcc, [])
  end

  @doc "Delivers given email and returns a Task"
  def deliver(email, context, extra_headers) do
    message = Mailman.Render.render(email, context.composer, extra_headers)
    Adapter.deliver(Mailman.Context.get_config(context), email, message)
  end

  def deliver(email, context) do
    deliver(email, context, [])
  end
end
