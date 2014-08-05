defmodule Mailman.Email do
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
