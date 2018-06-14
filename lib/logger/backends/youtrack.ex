defmodule Logger.Backends.Youtrack do
  @moduledoc """
  A module implementing an elixir logger backend that logs to youtrack.
  """

  @behaviour :gen_event

  require Logger

  alias Youtrack.Formatter

  defstruct host: nil,
            project: nil,
            token: nil,
            level: nil,
            format_summary: nil,
            format_description: nil,
            metadata: nil

  @default_format_summary "$level: $message\n"
  @default_format_description "$date $time\n$metadata\n"

  def init({__MODULE__, _opts}) do
    config = Application.get_env(:logger, :youtrack)

    if config do
      {:ok, init(config, %__MODULE__{})}
    else
      {:error, :ignore}
    end
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, init(options, state)}
  end

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

  def handle_info(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp init(config, state) when is_list(config) do
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

  defp log_event(
         %{host: host, token: token, project: project, level: _level} = state,
         summary,
         description
       ) do
    client = Youtrack.client(host, token)
    {:ok, response} = Youtrack.create_issue(client, project, summary, description)

    if response.status > 299 or response.status < 200 do
      Logger.error(
        "Request to #{response.url} failed with status #{response.status}.",
        ignore_youtrack_backend: true
      )
    end

    {:ok, state}
  end
end
