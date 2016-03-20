defmodule Mailman.Context do
  @moduledoc "Defines the configuration for both rendering and sending of messages"

  defstruct config: nil, composer: %Mailman.EexComposeConfig{}

  def get_config(%{config: config}) when not is_nil(config),
    do: config
  def get_config(_),
    do: get_mix_config

  defp get_mix_config do
    config = Application.get_all_env(:mailman)
    config_module = Keyword.get(config, :config_module) || detect_config_module

    new_config = config_module.__struct__
    {config_vars, _} = Keyword.split(config, Map.keys(new_config))
    new_config |> Map.merge(Enum.into(config_vars, %{}))
  end

  defp detect_config_module do
    relay = Application.get_env(:mailman, :relay)
    port = Application.get_env(:mailman, :port)
    cond do
      relay            -> Mailman.SmtpConfig
      is_integer(port) -> Mailman.LocalSmtpConfig
      true             -> Mailman.TestConfig
    end
  end
end
