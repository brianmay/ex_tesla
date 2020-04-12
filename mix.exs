defmodule ExTesla.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_tesla,
      version: "2.0.3",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Unofficial thin elixir wrapper for Tesla API.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Brian May"],
      licenses: ["GPL3"],
      links: %{"GitHub" => "https://github.com/brianmay/ex_tesla"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mojito, "~> 0.6.1"},
      {:jason, ">= 1.0.0"},
      {:ex_doc, "~> 0.21.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false}
    ]
  end
end
