defmodule Mailman.EexComposeConfig do
  @moduledoc "Defines the config for the Eex composer"

  defstruct root_path: "", assets_path: ""
end

defimpl Mailman.Composer, for: Mailman.EexComposeConfig do
  def compile_part(config, mode, email) do
    Mailman.EexComposer.compile_part(config, mode, email)
  end
end
