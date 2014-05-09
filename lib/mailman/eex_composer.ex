defmodule Mailman.EexComposer do
  def compile_text_part(config, mode, email) when mode in [:html, :text] do
    res = Path.join(config.root_path, email.name <> "." <> atom_to_binary(mode)  <> ".eex") |>
      File.read
    case res do
      {:ok, template} -> EEx.eval_string template, email.data
      _ -> nil
    end
  end

  def compile_part(config, :attachments, _) do
    []
  end

  def compile_part(config, mode, email) do
    compile_text_part(config, mode, email)
  end
end

