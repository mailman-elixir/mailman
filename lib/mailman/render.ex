defmodule Mailman.Render do

  @doc "Returns a tuple with all data needed for the underlying adapter to send"
  def render(email, composer) do
    compile_parts(email, composer) |>
      to_tuple(email) |>
      :mimemail.encode
  end

  def to_tuple(part, email) when is_tuple(part) do
    {
      mime_type_for(part),
      mime_subtype_for(part),
      [],
      parameters_for(part),
      elem(part, 1)
    }
  end

  def to_tuple(parts, email) when is_list(parts) do
    {
      mime_type_for(parts),
      mime_subtype_for(parts),
      headers_for(email),
      [],
      Enum.map(parts, &to_tuple(&1, email))
    }
  end

  def parameters_for({:attachment, body, attachment}) do
    [
      content_type_params_for(attachment),
      disposition_for(attachment),
      disposition_params_for(attachment)
    ]
  end

  def content_type_params_for(attachment) do
    { "content-type-params", [ { "Content-Transfer-Encoding", "base64" } ] }
  end

  def disposition_for(attachment) do
    { "disposition", "attachment" }
  end

  def disposition_params_for(attachment) do
    { "disposition-params", [{ "filename", attachment.file_path }] }
  end

  def parameters_for(part) do
    [
      { "content-type-params", [ { "Content-Transfer-Encoding", "quoted-printable" } ] },
      { "disposition", "inline" },
      { "disposition-params", [] }
    ]
  end

  def mime_type_for(parts) when is_list(parts) do
    "multipart"
  end

  def mime_type_for({type, _}) do
    "text"
  end

  def mime_type_for({_, _, attachment}) do
    attachment.mime_type
  end

  def mime_subtype_for(parts) when is_list(parts) do
    if Enum.find parts, fn(part) -> elem(part, 0) == :attachment end do
      "mixed"
    else
      "alternative"
    end
  end

  def mime_subtype_for({type, _}) do
    type
  end

  def mime_subtype_for({_, _, attachment}) do
    attachment.mime_sub_type
  end

  def headers_for(email) do
    [
      { "From", email.from },
      { "To", email.to |> normalize_addresses |> Enum.join(",") },
      { "Subject", email.subject },
      { "Cc",  email.cc |> as_list |> normalize_addresses |> Enum.join(", ") |> as_list },
      { "Bcc", email.bcc |> as_list |> normalize_addresses |> Enum.join(", ") |> as_list }
    ] |> Enum.filter fn(i) -> elem(i, 1) != [] end
  end

  def as_list(value) when is_list(value) do
    value
  end

  def as_list("") do
    []
  end

  def as_list(value) when is_binary(value) do
    [ value ]
  end

  def normalize_addresses(addresses) when is_list(addresses) do
    addresses |> Enum.map fn(address) ->
      case address |> String.split("<") |> Enum.count > 1 do
        true -> address
        false ->
          name = address |>
            String.split("@") |>
            List.first |>
            String.split(~r/([^\w\s]|_)/) |>
            Enum.map(&String.capitalize/1) |>
            Enum.join " "
          "#{name} <#{address}>"
      end
    end
  end

  def compile_parts(email, composer) do
    [
      { :html,  compile_part(:html, email, composer) },
      { :plain, compile_part(:text, email, composer) },
      Enum.map(email.attachments, fn(attachment) ->
        { :attachment, compile_part(:attachment, attachment, composer), attachment }
      end)
    ] |> List.flatten |>
         Enum.filter(&not_empty_tuple_value(&1))
  end

  def compile_part(type, email, composer) do
    Mailman.Composer.compile_part(composer, type, email)
  end

  @doc "Returns boolean saying if a value for a tuple is blank as a string or list"
  def not_empty_tuple_value(tuple) when is_tuple(tuple) do
    value = elem(tuple, 1)
    value != nil && value != [] && value != ""
  end

end
