defmodule Mailman.LocalServer do
  def start(port) do
    :gen_smtp_server.start :smtp_server_example, 
      [[], [{:allow_bare_newlines, :true}, {:port, port}]]
  end
end
