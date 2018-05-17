# youtrack_logger_backend

Application config
```elixir
config :logger,
  backends: [{Logger.Backend.Youtrack, :youtrack}]

config :logger, :youtrack,
  
  format_summary: "$level: $message\n", #optional
  format_description: "$date $time\n$metadata\n", #optional
  metadata: [:module, :file, :function, :line], #optional - describes $metadata
  
  host: "https://xxx.myjetbrains.com/youtrack",
  project: "xxx",
  level: :error #optional

# Add to prod.secret.exs

config :logger, :youtrack,
  token: "xxx"
```
