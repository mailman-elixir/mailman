defmodule Mailman do

  defrecord EnvelopeBody, text: "", html: ""
  defrecord EnvelopeHeader, from: "", to: [], subject: ""
  defrecord Envelope, header: EnvelopeHeader.new, body: EnvelopeBody.new

  defexception InvalidEnvelopeException, 
    message: "The envelope should have the recipient" do
    
  end

  def start_smtp do
    :gen_smtp_server.start(:smtp_server_example, [[port: 1465]])
  end

  def has_html?(envelope) do
    envelope.body.html != ""
  end

  def has_plain?(envelope) do
    envelope.body.text != "" 
  end

  def has_alternatives?(envelope) do
    has_html?(envelope) && has_plain?(envelope)
  end

  def render(envelope) do
    case has_alternatives?(envelope) do
      true -> render_alternatives(envelope)
      false -> case has_html?(envelope) do
        true -> render_alternatives_from_html(envelope)
        false -> render_plain(envelope)
      end
    end
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
    "#{plain_header} \r\n\r\n#{DataEncoding.quoted_from(envelope.body.text)}"
  end
  
  def html_part(envelope) do
    "#{html_header} \r\n\r\n#{DataEncoding.quoted_from(envelope.body.html)}"
  end

  def plain_from_html_part(envelope) do
    raise "Html parts without Plain counterparts not yet supported"
  end

  def header_for(envelope, to) do
    from = envelope.header.from
    content_type = main_content_type_for(envelope)
    "Subject: #{envelope.header.subject} \r\nFrom: #{from} \r\nTo: #{to} \r\nMIME-Version: 1.0 \r\n#{content_type} "
  end

  def boundary_for(envelope) do
    :erlang.list_to_binary(Enum.map(bitstring_to_list(:crypto.md5("#{envelope.body.text} #{envelope.body.html}")), 
      fn(x) -> integer_to_binary(x, 16) end))
  end

  def render_plain(envelope) do
    Enum.map envelope.header.to, fn(to) ->
      { to, "#{header_for(envelope, to)} \r\n\r\n#{DataEncoding.quoted_from(envelope.body.text)}" }
    end
  end

  def render_alternatives(envelope) do
    Enum.map envelope.header.to, fn(to) ->
      { to, "#{header_for(envelope, to)} \r\n\r\n--#{boundary_for(envelope)}\r\n#{plain_part(envelope)}\r\n\r\n--#{boundary_for(envelope)}\r\n#{html_part(envelope)}\r\n\r\n--#{boundary_for(envelope)}--\r\n " }
    end
  end

  def render_alternatives_from_html(envelope) do
    Enum.map envelope.header.to, fn(to) ->
      { to, "#{header_for(envelope, to)} \r\n\r\n#{plain_from_html_part(envelope)}\r\n\r\n#{html_part(envelope)}\r\n\r\n--#{boundary_for(envelope)}--\r\n " }
    end
  end

  defmacro __using__(_) do
    definitions =
      quote location: :keep do
        @doc """
        Returns an envelope record object which can then 
        be send with Mailman.deliver/1
        """
        def new(config) do
          Envelope.new
        end
      end

    quote do
      unquote(definitions)
    end
  end

end
