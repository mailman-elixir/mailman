defmodule Mailman.Email do
  @moduledoc "Struct representing an email message"

  defstruct subject: "",
    from: "",
    to: [],
    cc: [],
    bcc: [],
    attachments: [],
    data: %{},
    html: "",
    text: "",
    delivery: nil

    def parse(message) do
      Mailman.Parsing.parse message
    end

    def parse!(message) do
      Mailman.Parsing.parse! message
    end
end
