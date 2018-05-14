# youtrack_logger_backend

Application config
```elixir
config :logger,
  backends: [{Logger.Backend.Youtrack, :youtrack}]

config :logger, :youtrack,
  host: "https://xxx.myjetbrains.com/youtrack",
  project: "xxx",
  level: :error #optional

# Add to prod.secrets.exs

config :logger, :youtrack,
  token: "xxx"
```
