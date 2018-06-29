defmodule Logger.Backends.Youtrack do
  @moduledoc """
  A module implementing an elixir logger backend that logs to youtrack.
  """

  @behaviour :gen_event

  require Logger

  alias Youtrack.Formatter

  @required [:host, :project, :token]
  defstruct host: nil,
            project: nil,
            token: nil,
            level: nil,
            format_summary: nil,
            format_description: nil,
            metadata: nil

  @default_format_summary "$level: $message\n"
  @default_format_description "==Level==\n$level\n==Reported at==\n$date $time\n==Metadata==\n$metadata\n==Message==\n$message\n"

  @doc """
  Initial entry point on creating the gen event. Will create if the given config is valid.

  ## Parameters
    - any tuple

  ## Returns
    - tuple:
      - {:ok, %{_}}
      - {:error, :ignore}
  """
  @spec init(any) :: {:ok, map} | {:error, :ignore}
  def init({__MODULE__, _opts}) do
    config = Application.get_env(:logger, :youtrack)

    if config && required_keys_set?(config) do
      {:ok, configure(config, %__MODULE__{})}
    else
      Logger.error(
        "Youtrack Logger Backend: The given config was incomplete.",
        ignore_youtrack_backend: true
      )

      {:error, :ignore}
    end
  end

  @spec handle_call({:configure, list}, map) :: {:ok, any, map}
  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  @doc """
  Responsible logic for the actual logging.
  Checking if the level is acceptable to log.
  Generating the logging formats.
  Logging the resulting messages.

  ## Parameters:
    - a tuple containing the data and metadata
    - state: e.g. %Logger.Backends.Youtrack{_}
  """
  @spec handle_event(any, map) :: {:ok, map}
  def handle_event({_level, gl, __event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event(
        {level, _group_leader, {Logger, message, timestamp, metadata}},
        %Logger.Backends.Youtrack{level: min_level} = state
      )
      when is_atom(level) and is_binary(message) and is_list(metadata) and is_atom(min_level) do
    ignore_youtrack_backend = Keyword.get(metadata, :ignore_youtrack_backend, false)

    if Logger.compare_levels(level, min_level) != :lt && !ignore_youtrack_backend do
      description = Formatter.generate_description(level, message, timestamp, metadata, state)

      summary = Formatter.generate_summary(level, message, timestamp, metadata, state)
      log_event(state, summary, description)
    end

    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  @spec handle_info(any, map) :: {:ok, map}
  def handle_info(_, state) do
    {:ok, state}
  end

  @spec code_change(any, map, any) :: {:ok, map}
  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  @spec terminate(any, map) :: :ok
  def terminate(_reason, _state) do
    :ok
  end

  # configures the backend when initially creating
  # applying default params when possible
  # returning the state map with updated values
  @spec configure(list, map) :: map
  defp configure(config, state) when is_list(config) do
    host = Keyword.get(config, :host)
    project = Keyword.get(config, :project)
    token = Keyword.get(config, :token)
    level = Keyword.get(config, :level, :debug)
    format_summary_string = Keyword.get(config, :format_summary, @default_format_summary)
    format_summary = Logger.Formatter.compile(format_summary_string)

    format_description_string =
      Keyword.get(config, :format_description, @default_format_description)

    format_description = Logger.Formatter.compile(format_description_string)
    metadata = Keyword.get(config, :metadata)

    %{
      state
      | host: host,
        project: project,
        token: token,
        format_summary: format_summary,
        format_description: format_description,
        metadata: metadata,
        level: level
    }
  end

  # logging a given state
  # making a create_issue call by the use of a youtrack client
  # will log an error if the request failed
  @spec log_event(map, binary, binary) :: tuple
  defp log_event(
         %{host: host, token: token, project: project, level: _level} = state,
         summary,
         description
       ) do
    client = Youtrack.client(host, token)

    {:ok, %Tesla.Env{status: status, url: url}} =
      Youtrack.create_issue(client, project, summary, description)

    if status > 299 or status < 200 do
      Logger.error(
        "Request to #{url} failed with status #{status}.",
        ignore_youtrack_backend: true
      )

      {:error, state}
    end

    {:ok, state}
  end

  # give a config to be evaluated
  # returns true if all required config keys exist
  # otherwise returns false
  @spec required_keys_set?(list) :: boolean
  defp required_keys_set?(config) do
    keys_set?(config, @required)
  end

  # give a config as first parameter and a list of keys that are required
  # will return true or false
  @spec keys_set?(list, list) :: boolean
  defp keys_set?(_config, []) do
    true
  end

  defp keys_set?(config, [head_key | remaining_required_keys] = required)
       when is_list(required) and is_list(config) do
    if Keyword.has_key?(config, head_key) do
      keys_set?(config, remaining_required_keys)
    else
      false
    end
  end
end
