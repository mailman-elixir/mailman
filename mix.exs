defmodule Mailman.Mixfile do
  use Mix.Project

  def project do
    [ app: :mailman,
      name: "Mailman",
      source_url: "https://github.com/kamilc/mailman",
      homepage_url: "https://github.com/kamilc/mailman",
      description: "Library providing a clean way of defining mailers in Elixir apps",
      package: package,
      version: "0.2.2",
      elixir: "~> 1.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:ssl, :crypto, :eiconv, :gen_smtp]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      { :eiconv, github: "zotonic/eiconv" },
      { :gen_smtp, ">= 0.9.0" },
      { :ex_doc, ">= 0.11.4", only: :dev },
      { :earmark, ">= 0.0.0" }
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
