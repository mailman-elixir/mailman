defmodule Mailman.Parsing do
  @moduledoc "Functions for parsin mail messages into Elixir structs"

  def parse(message) when is_binary(message) do
    {:ok, parse(:mimemail.decode(message))}
  end

  @doc "Parses given mime mail and returns Email"
  def parse(raw) do
    %Mailman.Email{
      subject: get_header(raw, "Subject") || "",
      from: get_header(raw, "From") || "",
      to: get_header(raw, "To") || "",
      reply_to: get_header(raw, "reply-to") || "",
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
    case parse message_text do
      { :ok, parsed }    -> parsed
      { :error, reason } -> throw "Couldn't parse given message. #{reason}"
    end
  end

  def get_header(raw, name) do
    header = Enum.find all_headers(raw), fn({header_name, _}) ->
      header_name == name
    end
    if header != nil do
      value = elem(header, 1)
      cond do
        name == "To" || name == "Cc" || name == "Bcc" -> String.split(value, ",") |> Enum.map(&String.trim(&1))
        true -> value
      end
    else
      if name == "To" || name == "Cc" || name == "Bcc" do
        []
      else
        nil
      end
    end
  end

  def all_headers(raw) do
    elem(raw, 2)
  end

  def filename_from_raw(raw_part) do
    maybe_param = raw_parameters_for(raw_part) |>
      List.last |>
      elem(1) |>
      Enum.find(fn(p) ->
        elem(p, 0) == "filename"
      end)
    if maybe_param != nil do
      elem(maybe_param, 1)
    else
      nil
    end
  end

  def raw_parameters_for(raw_part) do
    elem(raw_part, 3)
  end

  def is_raw_attachement(raw_part) do
    case filename_from_raw(raw_part) do
      nil -> false
      _   -> true
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
    |> Enum.filter(&is_raw_attachement(&1))
    |> Enum.map(&raw_to_attachement(&1))
  end

  def raw_to_attachement(raw_part) do
    %Mailman.Attachment{
      file_name: filename_from_raw(raw_part),
      mime_type: get_type(raw_part),
      mime_sub_type: get_subtype(raw_part),
      data: get_raw_body(raw_part)
    }
  end

  def content_parts(raw) when is_tuple(raw) do
    body = get_raw_body(raw)
    cond do
      is_binary(body) -> [raw]
      is_list(body)   -> Enum.map(body, &content_parts(&1))
    end
    |> List.flatten
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
