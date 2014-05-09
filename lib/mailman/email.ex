defmodule Mailman.Email do
  defstruct name: "", 
    subject: "", 
    from: "", 
    to: [], 
    cc: [], 
    bcc: [], 
    attachments: [],
    data: %{}

end
