defmodule Mailman.Render do
  @moduledoc "Functions for rendering email messages into strings"

  @doc "Returns a tuple with all data needed for the underlying adapter to send"
  def render(email, composer, extra_headers \\ []) do
    email
    |> compile_parts(composer) # Returns a list of tuples
    |> nest_parts(email, extra_headers) # Nests the tuples and attaches necessary metadata
    |> :mimemail.encode
  end

  def nest_parts(parts, email, extra_headers) do
    {top_mime_type, top_mime_sub_type, _, _, top_content_part} = nested_content_part_tuples(parts)

    {
      top_mime_type,
      top_mime_sub_type,
      headers_for(email) ++ extra_headers,
      [],
      top_content_part
    }
  end

  def nested_content_part_tuples(parts) do
    plain_part_tuple = body_part_tuple(parts, :plain)
    html_part_tuple = body_part_tuple(parts, :html)
    inline_attachment_part_tuples = attachment_part_tuples(parts, "inline")
    attached_attachment_part_tuples = attachment_part_tuples(parts, "attachment")

    related_or_html_part_tuple = if Enum.empty?(inline_attachment_part_tuples) do
      html_part_tuple
    else
      if is_nil(html_part_tuple), do: nil, else:
        {"multipart", "related", [], [], [html_part_tuple | inline_attachment_part_tuples]}
    end

    alternative_or_plain_tuple = if is_nil(related_or_html_part_tuple) do
      plain_part_tuple
    else
      {"multipart", "alternative", [], [], [plain_part_tuple, related_or_html_part_tuple]}
    end

    mixed_or_alternative_tuple = if Enum.empty?(attached_attachment_part_tuples) do
      alternative_or_plain_tuple
    else
      if is_nil(alternative_or_plain_tuple), do: nil, else:
        {"multipart", "mixed", [], [], [alternative_or_plain_tuple | attached_attachment_part_tuples]}
    end

    mixed_or_alternative_tuple
  end

  @spec body_part_tuple([tuple()], atom()) :: nil | tuple()
  defp body_part_tuple(parts, type) do
    part = Enum.find(parts, &elem(&1, 0) == type)
    if is_nil(part) do
      nil
    else
      {
        mime_type_for(part),
        mime_subtype_for(part),
        headers_for(part),
        parameters_for(part),
        elem(part, 1)
      }
    end
  end

  @spec attachment_part_tuples([tuple()], String.t) :: list(tuple())
  defp attachment_part_tuples(parts, disposition) do
    parts
    |> Enum.filter(fn 
      {_, _, attachment} -> attachment.disposition == disposition
      _ -> false
    end)
    |> Enum.map(fn part -> {
      mime_type_for(part),
      mime_subtype_for(part),
      headers_for(part),
      parameters_for(part),
      elem(part, 1)
    }
    end)
  end

  def mime_type_for({_type, _}) do
    "text"
  end

  def mime_type_for({_, _, attachment}) do
    attachment.mime_type
  end

  def mime_subtype_for({type, _}) do
    type
  end

  def mime_subtype_for({_, _, attachment}) do
    attachment.mime_sub_type
  end

  def parameters_for({:attachment, _body, attachment}) do
    [
      {"transfer-encoding", "base64"},
      {"content-type-params", []},
      {"disposition", attachment.disposition},
      {"disposition-params", [{"filename", attachment.file_name}]}
    ]
  end

  def parameters_for(_part) do
    [
      {"transfer-encoding", "quoted-printable"},
      {"content-type-params", []},
      {"disposition", "inline"},
      {"disposition-params", []}
    ]
  end

  def headers_for({:plain, _body}), do: []
  def headers_for({:html, _body}), do: []
  def headers_for({:attachment, _body, %{disposition: "inline"} = attachment}) do
    attachment_id = URI.encode(attachment.file_name)
    [{"Content-ID", "<#{attachment_id}@mailman.attachment>"},
     {"X-Attachment-Id", attachment_id}]
  end
  def headers_for({:attachment, _body, _attachment}), do: []
  def headers_for(email) do
    [
      { "From", email.from },
      { "To", email.to |> normalize_addresses |> Enum.join(",") },
      { "Subject", email.subject },
      { "reply-to", email.reply_to },
      { "Cc",  email.cc |> as_list |> normalize_addresses |> Enum.join(", ") |> as_list },
      { "Bcc", email.bcc |> as_list |> normalize_addresses |> Enum.join(", ") |> as_list }
    ] |> Enum.filter(fn(i) -> elem(i, 1) != [] end)
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
    addresses |> Enum.map(fn(address) ->
      case address |> String.split("<") |> Enum.count > 1 do
        true -> address
        false ->
          name = address |>
            String.split("@") |>
            List.first |>
            String.split(~r/([^\w\s]|_)/) |>
            Enum.map(&String.capitalize/1) |>
            Enum.join(" ")
          "#{name} <#{address}>"
      end
    end)
  end

  def compile_parts(email, composer) do
    [{:plain, compile_part(:text, email, composer)},
     {:html, compile_part(:html, email, composer)},
      Enum.map(email.attachments, fn(attachment) ->
        {:attachment, compile_part(:attachment, attachment, composer), attachment}
      end)
    ]
    |> List.flatten
    |> Enum.filter(&not_empty_tuple_value(&1))
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
