defmodule Gigex.MixProject do
  use Mix.Project

  def project do
    [
      app: :gigex,
      version: "0.1.2",
      description: description(),
      package: package(),
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gigex.Application, []}
    ]
  end

  defp escript do
    [main_module: Gigex.CLI]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:floki, "~> 0.36.0"},
      {:burrito, "~> 1.1"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def releases do
    [
      gigex_cli: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64],
            windows: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end

  defp description() do
    """
    Gigex 🎸

    A scraper for gigs.
    """
  end

  defp package() do
    [
      files: [
        "lib",
        "LICENSE",
        "mix.exs",
        "mix.lock",
        "README.md"
      ],
      maintainers: ["Marco Milanesi"],
      licenses: ["GPL-3.0"],
      links: %{
        "GitHub" => "https://github.com/kpanic/gigex",
        "Contributors" => "https://github.com/kpanic/gigex/graphs/contributors",
        "Issues" => "https://github.com/kpanic/gigex/issues"
      }
    ]
  end
end
