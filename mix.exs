defmodule Mailman.Mixfile do
  use Mix.Project

  def project do
    [ app: :mailman,
      name: "Mailman",
      source_url: "https://github.com/kamilc/mailman",
      homepage_url: "https://github.com/kamilc/mailman",
      description: "Library providing a clean way of defining mailers in Elixir apps",
      package: package(),
      version: "0.4.0",
      elixir: "~> 1.0",
      deps: deps() ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:ssl, :crypto, :eiconv, :gen_smtp, :httpotion]]
  end

  # Returns the list of dependencies in the format:
  defp deps do
    [
      { :eiconv, github: "zotonic/eiconv" },
      { :gen_smtp, "~> 0.12.0" },
      { :ex_doc, ">= 0.16.3", only: :dev },
      { :httpotion, "~> 3.0.0" },
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
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
