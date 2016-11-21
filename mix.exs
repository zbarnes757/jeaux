defmodule Jeaux.Mixfile do
  use Mix.Project

  def project do
    [app: :jeaux,
     version: "0.6.0",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  def application, do: [applications: applications]

  defp applications, do: []

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:excoveralls, "~> 0.5", only: :test},
      {:credo, "~> 0.4", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    A library for validating http params and queries
    """
  end

  defp package do
    [
      maintainers: ["Zac Barnes <zac.barnes89@gmail.com>"],
      files: ["lib", "mix.exs", "README.md", "LICENSE",],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "http://github.com/zbarnes757/jeaux"
      }
    ]
  end
end
