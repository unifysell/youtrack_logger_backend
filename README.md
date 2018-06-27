# youtrack_logger_backend

[![Build Status](https://travis-ci.org/unifysell/youtrack_logger_backend.svg?branch=master)](https://travis-ci.org/unifysell/youtrack_logger_backend)

This is an elixir logger backend inspired by the onkel-dirtus/logger_file_backend.

## References

* the [hex package](https://hex.pm/packages/youtrack_logger_backend)
* the [hex documentation](https://hexdocs.pm/youtrack_logger_backend/readme.html)
* if you have found any issues with the package, please tell us [here](https://github.com/unifysell/youtrack_logger_backend/issues)

## Installation

Add to your deps inside the `mix.exs`:

```elixir
{:youtrack_logger_backend, "~> 0.1"}
```

Run `mix deps.get` to download it.

## Base Application config - required

Add the following to your configuration (this is the minimum required config beside the token):

```elixir
config :logger,
  backends: [{Logger.Backend.Youtrack, :youtrack}]

config :logger, :youtrack,
  host: "https://xxx.myjetbrains.com/youtrack",
  project: "xxx"
```

When configuring the youtrack backend, the keys `host`, `project` and `token` are required.
Add your youtrack url and the project you want to push your issues to.

## Add a youtrack PERMANENT TOKEN - required

Get this token on 'Profile'->'Update personal information and manage logins'->'Authentication' and create a new token or get an existing one here.
You can also have a look at the official manual: https://www.jetbrains.com/help/youtrack/standalone/Manage-Permanent-Token.html

It is recommended to store the secret information inside a separate config like `prod.secret.exs` and not adding it to your version control.

```elixir
config :logger, :youtrack,
  token: "xxx"
```

## More configuration options - optional

If you want to, you can also configure the following keys: `format_summary`, `format_description`, `metadata`, `level`.
They all have default settings, so only use them if you want to customize.
Your config could look like this:

```elixir
config :logger,
  backends: [{Logger.Backend.Youtrack, :youtrack}]

config :logger, :youtrack,
  host: "https://xxx.myjetbrains.com/youtrack",
  project: "xxx",
  format_summary: "$level: $message\n", #optional
  format_description: "$date $time\n$metadata\n", #optional
  metadata: [:module, :file, :function, :line], #optional - describes $metadata
  level: :error #optional
```


