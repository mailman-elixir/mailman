  defmodule Mailman.ExternalSmtpAdapter do
    use Mailman.Adapter

    defmacro __using__(_) do
      quote do
        import Mailman.ExternalSmtpAdapter
      end
    end

    defmacro config([do: code]) do
      quote do
        @__config HashDict.new
        unquote(code)
        def relay_config do
          [
            relay: (HashDict.get @__config, :relay, ""),
            username: (HashDict.get @__config, :username, ""),
            password: (HashDict.get @__config, :password, ""),
            port: (HashDict.get @__config, :port, 1111),
            ssl: (HashDict.get @__config, :ssl, false) #,
            #tls: (HashDict.get @__config, :tls, :never),
            #auth: (HashDict.get @__config, :auth, :always)
          ]
        end

        def deliver(envelope) do
          emails = Mailman.render(envelope)
          results = Enum.map emails, fn({to, message}) ->
            :gen_smtp_client.send_blocking {
              envelope.header.from, 
              [to], 
              message
              }, relay_config
          end
          { :ok, emails }
        end
      end
    end


    defmacro relay(markup) do
      quote do
        @__config (HashDict.put @__config, :relay, unquote(markup))
      end
    end

    defmacro username(markup) do
      quote do
        @__config (HashDict.put @__config, :username, unquote(markup))
      end
    end

    defmacro tls(markup) do
      quote do
        @__config (HashDict.put @__config, :tls, unquote(markup))
      end
    end

    defmacro auth(markup) do
      quote do
        @__config (HashDict.put @__config, :auth, unquote(markup))
      end
    end

    defmacro password(markup) do
      quote do
        @__config (HashDict.put @__config, :password, unquote(markup))
      end
    end

    defmacro port(markup) do
      quote do
        @__config (HashDict.put @__config, :port, unquote(markup))
      end
    end

    defmacro ssl(markup) do
      quote do
        @__config  (HashDict.put @__config, :ssl, unquote(markup))
      end
    end


  end

