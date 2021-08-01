defmodule Mailman.Mixfile do
  use Mix.Project

  @source_url "https://github.com/kamilc/mailman"
  @version "0.4.4"

  def project do
    [
      app: :mailman,
      name: "Mailman",
      version: @version,
      elixir: "~> 1.0",
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:ssl, :crypto, :eiconv, :gen_smtp, :httpoison]]
  end

  # Note that :eiconv encoder/decoder is used by gen_smtp as well,
  # and will not be replaced by the newer iconv (see https://github.com/gen-smtp/gen_smtp/issues/95)
  #
  # If the eiconv NIF fails to compile, try updating rebar:
  # $ mix local.rebar
  # $ rm -rf deps
  # $ rm -rf _build
  # $ mix deps.get
  # $ mix

  defp deps do
    [
      {:eiconv, "~> 1.0.0"},
      {:gen_smtp, "~> 1.1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:httpoison, "~> 1.6"},
      {:credo, "~> 1.5.0-rc.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CONTRIBUTORS.md",
        {:"LICENSE.md", [title: "License"]},
        "README.md",
        "guides/creating_emails.md",
        "guides/rendering_using_eex.md",
        "guides/smtp_adapter_config.md",
        "guides/local_and_test_adapter_config.md",
        "guides/configuration_tips.md",
        "guides/checking_for_successfully_delivery.md"
      ],
      groups_for_extras: [
        "Guides": Path.wildcard("guides/*.md"),
      ],
      main: "readme",
      source_url: @source_url,
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "Library providing a clean way of defining mailers in Elixir apps",
      files: ["lib", "docs", "LICENSE", "README", "mix.exs"],
      maintainers: ["Kamil Ciemniewski <ciemniewski.kamil@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
