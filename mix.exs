defmodule ExRaycast.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_raycast,
     version: "0.1.0",
     elixir: "~> 1.3",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:floki, "~> 0.11.0"}
    ]
  end

  defp package do
    %{
      "links" => %{"GitHub" => "https://github.com/techgaun/ex_raycast"}
    }
  end
end