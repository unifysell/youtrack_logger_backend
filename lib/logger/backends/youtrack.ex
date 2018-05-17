defmodule Logger.Backends.Youtrack do
  @moduledoc """
  A module implementing an elixir logger backend that logs to youtrack.
  """

  @behaviour :gen_event

  defstruct host: nil,
            project: nil,
            token: nil,
            level: nil,
            format_summary: nil,
            format_description: nil,
            metadata: nil

  @default_format_summary "$level: $message\n"
  @default_format_description "$date $time\n$metadata\n"

  def init({__MODULE__, opts}) do
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
        %{level: min_level} = state
      ) do
    if Logger.compare_levels(level, min_level) != :lt do
      description = generate_description(level, message, timestamp, metadata, state)
      summary = generate_summary(level, message, timestamp, metadata, state)
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

  defp generate_summary(level, message, timestamp, metadata, %{format_summary: format, metadata: keys} = state) do
    Logger.Formatter.format(format, level, message, timestamp, take_metadata(metadata, keys))
    |> to_string()
  end

  defp generate_description(level, message, timestamp, metadata, %{format_description: format, metadata: keys} = state) do
    Logger.Formatter.format(format, level, message, timestamp, take_metadata(metadata, keys))
    |> to_string()
  end

  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    reduced_metadata = Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
    |> Enum.reverse()
    for {key, value} <- reduced_metadata, do: {"'''"<>to_string(key)<>"'''", to_string(value)<>"\n"}
  end

  defp init(config, state) do
    host = Keyword.get(config, :host)
    project = Keyword.get(config, :project)
    token = Keyword.get(config, :token)
    level = Keyword.get(config, :level, :debug)
    format_summary_string = Keyword.get(config, :format_summary, @default_format_summary)
    format_summary = Logger.Formatter.compile(format_summary_string)
    format_description_string = Keyword.get(config, :format_description, @default_format_description)
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
         %{host: host, token: token, project: project, level: level} = state,
         summary,
         description
       ) do
    client = Youtrack.client(host, token)
    {:ok, response} = Youtrack.create_issue(client, project, summary, description)
    {:ok, state}
  end
end
