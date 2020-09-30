defmodule Mailman.Parsing do
  @moduledoc "Functions for parsin mail messages into Elixir structs"

  @doc "Parses given mime mail and returns Email"
  def parse(message) when is_binary(message) do
    {:ok, parse(:mimemail.decode(message))}
  end
  def parse(raw) do
    %Mailman.Email{
      subject: get_header(raw, "Subject") || "",
      from: get_header(raw, "From") || "",
      to: get_header(raw, "To") || "",
      reply_to: get_header(raw, "Reply-To") || "",
      cc: get_header(raw, "Cc") || "",
      bcc: get_header(raw, "Bcc") || "",
      attachments: get_attachments(raw),
      html: get_html(raw) || "",
      text: get_text(raw) || "",
      delivery: get_delivery(raw) || ""
    }
  end

  @doc "Parses the message and returns Email"
  def parse!(message_text) do
    case parse(message_text) do
      {:ok, parsed} -> parsed
      {:error, reason} -> throw("Couldn't parse given message. #{reason}")
    end
  end

  def get_header(raw, name) do
    header =
      Enum.find(get_headers(raw), fn {header_name, _} ->
        header_name == name
      end)

    if header != nil do
      value = elem(header, 1)

      if name == "To" || name == "Cc" || name == "Bcc" do
        value |> String.split(",") |> Enum.map(&String.trim(&1))
      else
        value
      end
    else
      if name == "To" || name == "Cc" || name == "Bcc" do
        []
      else
        nil
      end
    end
  end

  def get_headers({_mime_type, _mime_subtype, headers, _parameters, _content}) do
    headers
  end

  def filename_from_raw(raw_part) do
    maybe_param =
      raw_part
      |> get_parameters
      |> Map.get(:disposition_params)
      |> Enum.find(fn p ->
        elem(p, 0) == "filename"
      end)

    if maybe_param != nil do
      elem(maybe_param, 1)
    else
      nil
    end
  end

  def get_parameters({_mime_type, _mime_subtype, _headers, parameters, _content}) do
    parameters
  end

  def is_raw_attachment(raw_part) do
    case filename_from_raw(raw_part) do
      nil -> false
      _ -> true
    end
  end

  def is_raw_html_part(raw) do
    get_type(raw) == "text" && get_subtype(raw) == "html"
  end

  def is_raw_plain_part(raw) do
    get_type(raw) == "text" && get_subtype(raw) == "plain"
  end

  def get_attachments(raw) do
    raw
    |> content_parts
    |> Enum.filter(&is_raw_attachment(&1))
    |> Enum.map(&raw_to_attachment(&1))
  end

  def raw_to_attachment(raw_part) do
    %Mailman.Attachment{
      file_name: filename_from_raw(raw_part),
      mime_type: get_type(raw_part),
      mime_sub_type: get_subtype(raw_part),
      data: get_raw_body(raw_part)
    }
  end



  def content_parts(raw) when is_tuple(raw) do
    body = get_raw_body(raw)

    parts_from_body =
      cond do
        is_binary(body) -> [raw]
        is_list(body) -> Enum.map(body, &content_parts(&1))
        true -> []
      end

    List.flatten(parts_from_body)
  end

  def get_type(raw) when is_tuple(raw) do
    raw |> elem(0)
  end

  def get_subtype(raw) when is_tuple(raw) do
    raw |> elem(1)
  end

  def get_raw_body(raw) when is_tuple(raw) do
    raw |> elem(4)
  end

  def get_html(raw) do
    case Enum.find(content_parts(raw), &is_raw_html_part(&1)) do
      nil -> nil
      html_part -> get_raw_body(html_part)
    end
  end

  def get_text(raw) do
    case Enum.find(content_parts(raw), &is_raw_plain_part(&1)) do
      nil -> nil
      plain_part -> get_raw_body(plain_part)
    end
  end

  def get_delivery(raw) do
    get_header(raw, "Date")
  end
end
