defmodule Mailman.EexComposeConfig do
  @moduledoc "Defines the config for the Eex composer"

  defstruct root_path: "", assets_path: "", 
            text_file: false, html_file: false,
            text_file_path: "", html_file_path: ""
end

defimpl Mailman.Composer, for: Mailman.EexComposeConfig do
  def compile_part(config, mode, email) do
    Mailman.EexComposer.compile_part(config, mode, email)
  end
end
