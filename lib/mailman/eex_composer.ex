defmodule Mailman.EexComposer do
  @moduledoc "Provides functions for rendering from Eex template files"

  def compile_part(_config, :html, %{html: template, data: data}) do
    case data do
      %{} -> template
      data -> EEx.eval_string template, data
    end
  end

  def compile_part(_config, :text, %{text: template, data: data}) do
    case data do
      %{} -> template
      data -> EEx.eval_string template, data
    end
  end

  def compile_part(_config, :attachment, attachment) do
    attachment.data
  end
end

