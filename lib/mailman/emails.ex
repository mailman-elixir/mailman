defmodule Mailman.Emails do

  defmacro compose(name, data, [do: code]) do
    quote [location: :keep] do
      def get(unquote(name), unquote(data)) do
        var!(__envelope_context) = HashDict.new
        unquote code

        template = unquote(name)

        template_text_path = Path.join(composer.templates_root, atom_to_binary(template) <> ".text.eex")
        template_html_path = Path.join(composer.templates_root, atom_to_binary(template) <> ".html.eex")
        {text_read_status, maybe_template_text} = File.read template_text_path
        {html_read_status, maybe_template_html} = File.read template_html_path

        template_text = if text_read_status == :ok do
          maybe_template_text
        else
          ""
        end

        template_html = if html_read_status == :ok do
          maybe_template_html
        else
          ""
        end

        msg_from = HashDict.get(var!(__envelope_context), :from, @default_from)
        data = HashDict.get(var!(__envelope_context), :data, HashDict.new) |> HashDict.to_list
        try do
          text_body = EEx.eval_string template_text, data
          html_body = EEx.eval_string template_html, data
          body = Mailman.EnvelopeBody.new(text: text_body, html: html_body)
          subject = HashDict.get(var!(__envelope_context), :subject, "")
          to = HashDict.get(var!(__envelope_context), :to, [])
          header = Mailman.EnvelopeHeader.new(from: msg_from, subject: subject, to: to)
          { :ok, Mailman.Envelope.new(body: body, header: header) }
        rescue
          x in CompileError ->
            { :error, "There were errors in #{template} email template: " <> Regex.replace(%r/nofile:1: /, x.message, "") }
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Mailman.Emails

      def composer do
        {:ok, composer} = Keyword.fetch(unquote(_opts), :composer)
        composer
      end
    end
  end

  defmacro template(markup) do
    quote do
      var!(__envelope_context )= HashDict.put var!(__envelope_context),
        :template, unquote(markup)
    end
  end

  defmacro to(markup) do
    quote do
      var!(__envelope_context )= HashDict.put var!(__envelope_context),
        :to, unquote(markup)
    end
  end

  defmacro from(text) do
    quote do
      var!(__envelope_context )= HashDict.put var!(__envelope_context),
        :from, unquote(text)
    end
  end

  defmacro subject(text) do
    quote do
      var!(__envelope_context )= HashDict.put var!(__envelope_context),
        :subject, unquote(text)
    end
  end

  defmacro data(name, variable) do
    quote do
      var!(__data_context )= case HashDict.fetch var!(__envelope_context), :data do
        {:ok, data_ctx} -> data_ctx
        :error          -> HashDict.new
      end

      var!(__data_context )= HashDict.put var!(__data_context), 
        unquote(name), unquote(variable)

      var!(__envelope_context )= HashDict.put var!(__envelope_context),
        :data, var!(__data_context
    )end
  end

  defmacro default_from(from) do
    quote do
      @default_from unquote(from)
    end
  end


end
