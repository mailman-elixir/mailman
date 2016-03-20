defmodule Mailman.ContextTest do
  use ExUnit.Case, async: false

  alias Mailman.Context

  setup do
    original_config = Application.get_all_env(:mailman)

    on_exit fn ->
      new_config = Application.get_all_env(:mailman)
      {_, new_config} = Keyword.split(new_config, Keyword.keys(original_config))
      for {key, value} <- original_config do
        Application.put_env(:mailman, key, value)
      end
      for {key, _} <- new_config do
        Application.put_env(:mailman, key, nil)
      end
    end

    :ok
  end

  test "returns the config configured in a context" do
    config = %Mailman.TestConfig{}

    assert config == Context.get_config(%Context{
      config: config
    })
  end

  test "returns a SMTP configuration when :relay is specified in application config" do
    relay_host = "some-smtp-server.example.com"
    Application.put_env(:mailman, :relay, relay_host)
    Application.put_env(:mailman, :port, 587)

    config = Context.get_config(%Context{})
    assert %Mailman.SmtpConfig{} = config
    assert config.relay == relay_host
    assert config.port == 587
  end

  test "returns a local SMTP configuration when only :port is specified in application config" do
    Application.put_env(:mailman, :port, 25)

    config = Context.get_config(%Context{})
    assert %Mailman.LocalSmtpConfig{} = config
    assert config.port == 25
  end

  test "returns a test configuration when nothing is specified in the application config" do
    config = Context.get_config(%Context{})
    assert %Mailman.TestConfig{} = config
  end

  test "returns a SMTP configuration when explicitly given a config module" do
    Application.put_env(:mailman, :config_module, Mailman.SmtpConfig)
    Application.put_env(:mailman, :port, 25)

    config = Context.get_config(%Context{})
    assert %Mailman.SmtpConfig{} = config
    assert config.port == 25
  end

  test "returns a local SMTP configuration when explicitly given a config module" do
    Application.put_env(:mailman, :config_module, Mailman.LocalSmtpConfig)
    Application.put_env(:mailman, :port, 25)

    config = Context.get_config(%Context{})
    assert %Mailman.LocalSmtpConfig{} = config
    assert config.port == 25
  end

  test "returns a test configuration when explicitly given a config module" do
    Application.put_env(:mailman, :config_module, Mailman.TestConfig)
    Application.put_env(:mailman, :store_deliveries, false)

    config = Context.get_config(%Context{})
    assert %Mailman.TestConfig{} = config
    assert config.store_deliveries == false
  end
end
