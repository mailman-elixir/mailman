defmodule Mailman.Emails do
  
  @doc "Returns a tuple with all data needed for the underlying adapter to send"
  def render(email, composer) do
    to_envelope(email, composer) |> to_message
  end

  def to_envelope(email, composer) do
    %Mailman.Envelope{
      subject: email.subject,
      from: email.from,
      to: email.to,
      cc: email.cc,
      bcc: email.bcc,
      parts: compile_parts(email, composer)
      }
  end

  def compile_parts(email, composer) do
    [
      html: Mailman.Composer.compile_part(composer, :html, email),
      plain: Mailman.Composer.compile_part(composer, :text, email),
      attachments: Enum.map(email.attachments, &Mailman.Composer.compile_part(composer, :attachment, &1))
    ]
  end

  def to_message(envelope)  do
    case has_alternatives?(envelope) do
      true -> compile_alternatives(envelope)
      false -> case has_html?(envelope) do
        true -> compile_alternatives_from_html(envelope)
        false -> compile_plain(envelope)
      end
    end
  end

  def has_html?(envelope) do
    envelope.parts[:html] != nil
  end

  def has_plain?(envelope) do
    envelope.parts[:plain] != nil
  end

  def has_alternatives?(envelope) do
    has_html?(envelope) && has_plain?(envelope)
  end

  def compile_plain(envelope)  do
    "#{header_for(envelope)} \r\n\r\n#{DataEncoding.quoted_from(envelope.parts[:plain])}" 
  end

  def compile_alternatives(envelope)  do
    "#{header_for(envelope)} \r\n\r\n--#{boundary_for(envelope)}\r\n#{plain_part(envelope)}\r\n\r\n--#{boundary_for(envelope)}\r\n#{html_part(envelope)}\r\n\r\n--#{boundary_for(envelope)}--\r\n " 
  end

  def compile_alternatives_from_html(envelope)  do
    "#{header_for(envelope)} \r\n\r\n#{plain_from_html_part(envelope)}\r\n\r\n#{html_part(envelope)}\r\n\r\n--#{boundary_for(envelope)}--\r\n " 
  end
  
  def plain_header do
    "Content-Type: text/plain;\r\n\tcharset=utf-8\r\nContent-Transfer-Encoding: quoted-printable"
  end
  
  def html_header do
    "Content-Type: text/html;\r\n\tcharset=utf-8\r\nContent-Transfer-Encoding: quoted-printable"
  end

  def alternatives_header(envelope) do
    "Content-Type: multipart/alternative; boundary=#{boundary_for(envelope)}"
  end

  def main_content_type_for(envelope) do
    case has_alternatives?(envelope) || has_html?(envelope) do
      true  -> alternatives_header(envelope)
      false -> plain_header
    end
  end

  def plain_part(envelope) do
    "#{plain_header} \r\n\r\n#{DataEncoding.quoted_from(envelope.parts[:plain])}"
  end

  def html_part(envelope) do
    "#{html_header} \r\n\r\n#{DataEncoding.quoted_from(envelope.parts[:html])}"
  end

  def plain_from_html_part(_) do
    raise "Html parts without Plain counterparts not yet supported"
  end

  def header_for(envelope) do
    content_type = main_content_type_for(envelope)
    [ 
      "Subject: #{envelope.subject}", 
      "From: #{envelope.from}", 
      "To: #{envelope.to}",
      "Cc: #{Enum.join(envelope.cc, ", ")}",
      "Bcc: #{Enum.join(envelope.bcc, ", ")}",
      "MIME-Version: 1.0", 
      "#{content_type} "
    ] |> Enum.join " \r\n"
  end

  def boundary_for(envelope) do
    :erlang.list_to_binary(Enum.map(bitstring_to_list(:crypto.hash(:md5, "#{envelope.parts[:plain]} #{envelope.parts[:html]}")), 
      fn(x) -> integer_to_binary(x, 16) end))
  end

end
