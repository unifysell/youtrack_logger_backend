defmodule Logger.Backends.Youtrack do
  @moduledoc """
  A module implementing an elixir logger backend that logs to youtrack.
  """

  @behaviour :gen_event

  defstruct host: nil,
            project: nil,
            token: nil,
            level: nil

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
        {level, _group_leader, {Logger, message, _timestamp, metadata}},
        %{level: min_level} = state
      ) do
    if Logger.compare_levels(level, min_level) != :lt do
      description = generate_description(metadata)
      summary = generate_summary(message, level)
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

  def terminate(reason, _state) do
    IO.inspect(reason, label: "REASON")
    :ok
  end

  defp generate_description(metadata) do
    module = metadata[:module]
    function = metadata[:function]
    file = metadata[:file]
    line = metadata[:line]

    "module: " <>
      to_string(module) <>
      "\n function: " <> function <> "\n file: " <> file <> "\n line: " <> to_string(line)
  end

  defp init(config, state) do
    host = Keyword.get(config, :host)
    project = Keyword.get(config, :project)
    token = Keyword.get(config, :token)
    level = Keyword.get(config, :level, :debug)

    %{
      state
      | host: host,
        project: project,
        token: token,
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
    IO.inspect(response)
    {:ok, state}
  end
end
