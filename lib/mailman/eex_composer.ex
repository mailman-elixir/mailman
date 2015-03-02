defmodule Mailman.EexComposer do
  @moduledoc "Provides functions for rendering from Eex template files"

  def compile_text_part(_config, mode, email) when mode in [:html, :text] do
    template = email.text
    case email.data do
      %{} -> template
      data -> EEx.eval_string template, data
    end
  end

  def compile_part(_config, :attachment, attachment) do
    attachment.data
  end

  def compile_part(config, mode, email) do
    compile_text_part(config, mode, email)
  end
end

