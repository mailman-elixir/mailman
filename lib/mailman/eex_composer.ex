defmodule Mailman.EexComposer do
  def compile_text_part(config, mode, email) when mode in [:html, :text] do
    template = email.text
    case email.data do
      %{} -> template
      data -> EEx.eval_string template, data
    end
  end

  def compile_part(config, :attachment, attachment) do
    attachment.data
  end

  def compile_part(config, mode, email) do
    compile_text_part(config, mode, email)
  end
end

