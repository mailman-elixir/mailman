defmodule Mailman do

  @doc "Protocol for implementing different medium of emails delivery"
  defprotocol Adapter do
    def deliver(context, email, message)
  end

  @doc "Protocol for implementing different template systems for compiling email bodies"
  defprotocol Composer do
    def compile_part(config, mode, email)
  end

  @doc "Delivers given email and returns a Task"
  def deliver(email, context) do
    message = Mailman.Render.render(email, context.composer)
    Adapter.deliver(context.config, email, message)
  end

  @doc "Delivers given email to all addresses and returns a list of Tasks"
  def deliver(email, context, :send_cc_and_bcc) do
    bcc_list = email.bcc
    cleaned_email = %Mailman.Email{email | bcc: []}
    message = Mailman.Render.render(cleaned_email, context.composer)

    to_task = [Adapter.deliver(context.config, email, message)]

    cc_tasks = email.cc |> Enum.map(fn(address) ->  
      cc_envelope = %Mailman.Email{email | to: [address]}
      Adapter.deliver(context.config, cc_envelope, message)
    end)

    bcc_tasks = bcc_list |> Enum.map(fn(address) ->  
      bcc_envelope = %Mailman.Email{email | to: [address]}
      bcc_message = %Mailman.Email{email | bcc: [address]}
      message = Mailman.Render.render(bcc_message, context.composer)
      Adapter.deliver(context.config, bcc_envelope, message)
    end)

    to_task ++ cc_tasks ++ bcc_tasks
  end
end
