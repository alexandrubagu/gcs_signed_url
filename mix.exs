defmodule GcsSignedUrl.MixProject do
  use Mix.Project

  def project do
    [
      app: :gcs_signed_url,
      version: "0.1.0",
      elixir: "~> 1.5",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_deps: :transitive,
        plt_add_apps: [:mix, :public_key],
        flags: [:race_conditions, :no_opaque]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.1"}
    ]
  end

  defp package do
    [
      name: :gcs_signed_url,
      description: "Create Signed URLs for Google Cloud Storage in Elixir",
      files: ["lib", "config", "mix.exs", "README*"],
      maintainers: ["Bagu Alexandru Bogdan"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/alexandrubagu/gcs_signed_url",
        "Docs" => "https://github.com/alexandrubagu/gcs_signed_url",
        "Website" => "http://www.alexandrubagu.info"
      }
    ]
  end
end
