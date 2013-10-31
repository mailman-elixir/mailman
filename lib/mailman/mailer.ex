defmodule Mailman.Mailer do
  defmacro __using__(_opts) do
    quote do
      def adapter do
        {:ok, adapter} = Keyword.fetch(unquote(_opts), :adapter)
        adapter
      end
      def send(envelope) do
        adapter.deliver envelope
      end
    end
  end
end
