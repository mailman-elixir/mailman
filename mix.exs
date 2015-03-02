defmodule Mailman.Mixfile do
  use Mix.Project

  def project do
    [ app: :mailman,
      name: "Mailman",
      source_url: "https://github.com/kamilc/mailman",
      homepage_url: "https://github.com/kamilc/mailman",
      description: "Library providing a clean way of defining mailers in Elixir apps",
      files: ["lib", "docs", "LICENSE", "README"],
      contributors: ["Kamil Ciemniewski <ciemniewski.kamil@gmail.com>"],
      licenses: ["MIT"],
      version: "0.1.0",
      elixir: "~> 1.0.0",
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
      { :gen_smtp, ~r/0\.9/ },
      { :ex_doc },
      { :earmark, ">= 0.0.0" }
    ]
  end
end
