defmodule Mailman.Context do
  @moduledoc "Defines the configuration for both rendering and sending of messages"

  defstruct config: nil, composer: %Mailman.EexComposeConfig{}

  def get_config(context) do
    case context.config do
      # if config in context is nil, read it from config.exs
      nil -> get_mix_config()
      _   -> context.config
    end
  end

  defp get_mix_config do
    app_config = Map.new(Application.get_all_env(:mailman))
    {config_adapter, adapter_config} = Map.pop(app_config, :adapter)
    adapter = case config_adapter do
      nil -> guess_adapter(adapter_config)
      _ -> config_adapter
    end
    struct(adapter, adapter_config)
  end

  defp guess_adapter(config) do
    relay = Map.get(config, :relay)
    port = Map.get(config, :port)
    cond do
      relay -> mix_smtp_config relay
      is_integer(port) -> mix_local_config port
      true -> mix_test_config()
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
