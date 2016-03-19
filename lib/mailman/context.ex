defmodule Mailman.Context do
  @moduledoc "Defines the configuration for both rendering and sending of messages"
 
  defstruct config: nil, composer: %Mailman.EexComposeConfig{}

  def get_config(context) do
    case context.config do
      # if config in context is nil, read it from config.exs
      nil -> get_mix_config
      _   -> context.config
    end
  end

  defp get_mix_config do
    relay = Application.get_env(:mailman, :relay)
    port = Application.get_env(:mailman, :port)
    case {relay, port} do
      {nil, nil} ->  mix_test_config
      {nil, port} -> mix_local_config port
      {relay, port} -> mix_smtp_config relay
    end
  end

  defp mix_smtp_config(relay) do
    %Mailman.SmtpConfig{
      relay: relay,
      username: Application.get_env(:mailman, :username, ""),
      password: Application.get_env(:mailman, :password, ""),
      port: Application.get_env(:mailman, :port, 1111),
      ssl: Application.get_env(:mailman, :ssl, false),
      tls: Application.get_env(:mailman, :tls, :never),
      auth: Application.get_env(:mailman, :auth, :always)
    }
  end

  defp mix_local_config(port) do
    %Mailman.LocalSmtpConfig{
      port: port
    }
  end

  defp mix_test_config do
    %Mailman.TestConfig{}
  end
  
end
