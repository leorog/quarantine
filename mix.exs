defmodule Quarantine.MixProject do
  use Mix.Project

  def project do
    [
      app: :quarantine,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Quarantine.Application, []}
    ]
  end

  defp deps do
    []
  end

  defp description do
    """
    Quarantine is a tiny OTP application for feature toggles.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Leonardo Rogerio"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/leorog/quarantine"
      }
    ]
  end
end
