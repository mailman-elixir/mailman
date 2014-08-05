defmodule Mailman.EexComposer do
  def compile_text_part(config, mode, email) when mode in [:html, :text] do
    res = Path.join(config.root_path, email.name <> "." <> Atom.to_string(mode)  <> ".eex") |>
      File.read
    case res do
      {:ok, template} -> 
        case email.data do
          %{} -> template
          data -> EEx.eval_string template, data
        end
      _ -> nil
    end
  end

  def compile_part(config, :attachment, attachment) do
    attachment.data
  end

  def compile_part(config, mode, email) do
    if mode == :text do
      DataEncoding.quoted_from email.text
    else
      DataEncoding.quoted_from email.html
    end
  end
end

