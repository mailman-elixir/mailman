defmodule Mailman.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mailman,
      name: "Mailman",
      source_url: "https://github.com/kamilc/mailman",
      homepage_url: "https://github.com/kamilc/mailman",
      description: "Library providing a clean way of defining mailers in Elixir apps",
      package: package(),
      version: "0.4.3",
      elixir: "~> 1.0",
      deps: deps(),
      docs: docs(),
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
  #> mix local.rebar
  #> rm -rf deps
  #> rm -rf _build
  #> mix deps.get
  #> mix

  # Returns the list of dependencies in the format:
  defp deps do
    [
      {:eiconv, "~> 1.0.0"},
      {:gen_smtp, "~> 1.0.1"},
      {:ex_doc, ">= 0.19.1", only: :dev},
      {:httpoison, "~> 1.6"},
      {:credo, "~> 1.5.0-rc.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "overview",
      formatter_opts: [gfm: true],
      source_url: "https://github.com/mailman-elixir/mailman",
      extras: [
        "docs/Overview.md",
        "docs/Email.md",
        "docs/Rendering.md",
        "docs/SmtpAdapter.md",
        "docs/LocalTestAdapters.md",
        "docs/MixConfig.md",
        "docs/Delivery.md",
      ]
    ]
  end

  defp package do
    [
      files: ["lib", "docs", "LICENSE", "README", "mix.exs"],
      maintainers: ["Kamil Ciemniewski <ciemniewski.kamil@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/kamilc/mailman",
        "Docs" => "http://hexdocs.pm/mailman"
      }
    ]
  end
end
