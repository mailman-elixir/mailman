defmodule Mailman.ConfigTest do
  use ExUnit.Case, async: true

  test "defaults to test config" do
    context = %Mailman.Context{}
    config = Mailman.Context.get_config(context)
    assert config == %Mailman.TestConfig{}
  end

  test "returns SMTP config if relay is given" do
    Application.put_env(:mailman, :relay, "test")
    Application.put_env(:mailman, :port, 2345)
    context = %Mailman.Context{}

    config = Mailman.Context.get_config(context)

    assert config == %Mailman.SmtpConfig{relay: "test", port: 2345}

    Application.delete_env(:mailman, :relay)
    Application.delete_env(:mailman, :port)
  end

  test "returns local SMTP config if only port is given" do
    Application.put_env(:mailman, :port, 1234)
    context = %Mailman.Context{}

    config = Mailman.Context.get_config(context)

    assert config == %Mailman.LocalSmtpConfig{port: 1234}

    Application.delete_env(:mailman, :port)
  end

  defmodule FakeAdapter do
    defstruct some_config: "default value"
  end

  test "uses explicitely passed adapter" do
    Application.put_env(:mailman, :adapter, FakeAdapter)
    Application.put_env(:mailman, :some_config, "overriden value")
    context = %Mailman.Context{}

    config = Mailman.Context.get_config(context)

    assert config == %FakeAdapter{some_config: "overriden value"}

    Application.delete_env(:mailman, :adapter)
    Application.delete_env(:mailman, :some_config)
  end
end
