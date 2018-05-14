use Mix.Config

config :tesla, adapter: Tesla.Adapter.Hackney
config :tesla, Tesla.Middleware.Logger, debug: true

import_config "#{Mix.env()}.exs"
