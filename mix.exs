defmodule GcsSignedUrl.MixProject do
  use Mix.Project

  @source_url "https://github.com/alexandrubagu/gcs_signed_url"
  @version "0.4.2"

  def project do
    [
      app: :gcs_signed_url,
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: cli_env(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: dialyzer(),
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: "v#{@version}",
        source_url: @source_url
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.travis": :test,
      "coveralls.github": :test
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5-pre", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix, :public_key],
      plt_core_path: "priv/plts",
      plt_local_path: "priv/plts"
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test_support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :gcs_signed_url,
      description: "Create Signed URLs for Google Cloud Storage in Elixir",
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: ["Bagu Alexandru Bogdan"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @source_url,
        "Website" => "http://www.alexandrubagu.info"
      }
    ]
  end
end
