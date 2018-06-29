use Mix.Config

#disable console log
config :logger,
  backends: [:console]

config :logger, :console, level: :error
