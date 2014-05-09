defmodule Mailman.Envelope do
  defstruct subject: "",
    parts: %{
      html: "",
      plain: "",
      attachments: []
      },
    from: "",
    to: [],
    cc: [],
    bcc: []
end
