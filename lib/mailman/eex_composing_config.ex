defmodule Mailman.EexComposeConfig do
  defstruct root_path: ""
end

defimpl Mailman.Composer, for: Mailman.EexComposeConfig do
  def compile_part(config, mode, email) do
    Mailman.EexComposer.compile_part(config, mode, email)
  end
end
