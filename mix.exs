defmodule YoutrackLoggerBackend.Mixfile do
  use Mix.Project

  def project do
    [
      app: :youtrack_logger_backend,
      version: "0.0.1",
      elixir: "~> 1.0",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [application: []]
  end

  defp description do
    "Logger backend that writes to a youtrack instance"
  end

  defp package do
    [
      maintainers: ["unifysell", "cstaud"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/unifysell/youtrack_logger_backend"}
    ]
  end

  defp deps do
    [{:credo, "~> 0.9", only: [:dev, :test]}]
  end
end
