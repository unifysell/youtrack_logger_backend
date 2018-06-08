use Mix.Config

config :logger,
  backends: [{Logger.Backends.Youtrack, :error_log}]
