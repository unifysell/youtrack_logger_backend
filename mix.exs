defmodule YoutrackLoggerBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :youtrack_logger_backend,
      version: "0.1.0-beta.3",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Youtrack Logger Backend",
      source_url: "https://github.com/unifysell/youtrack_logger_backend"
    ]
  end

  def application do
    [applications: [:hackney]]
  end

  defp description do
    "Logger backend that writes to a youtrack instance"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["unifysell", "cstaud"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/unifysell/youtrack_logger_backend"}
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.9", only: [:dev, :test]},
      {:tesla, "~> 1.0.0-beta.1"},
      {:poison, "~> 3.1"},
      {:hackney, "~>1.6"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
