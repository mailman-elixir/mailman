defmodule Mailman do

  defrecord Envelope, to: "", from: "", body: {}, context: {}

  defexception InvalidEnvelopeException, message: "The envelope should have the recipient" do
    
  end

  @doc """
  Delivers prepared envelope to the recipient.
  """
  def deliver(Envelope[to: ""]) do
    raise InvalidEnvelopeException
  end

  def deliver(envelope) do

  end

  defmacro __using__(_) do
    definitions =
      quote location: :keep do
        @doc """
        Returns an envelope record object which can then be send with Mailman.deliver/1
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
