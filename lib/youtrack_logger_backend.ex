defmodule YoutrackLoggerBackend do
  @moduledoc """
  A module implementing an elixir logger backend that writes to youtrack.
  """

  @behaviour :gen_event

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name}) do
    {:ok, :ok, configure(name, opts)}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    # call actual log_event functionality
    IO.inspect("Logged it")
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  defp configure(name, opts) do
    state = %{
      name: nil,
      url: nil,
      io_device: nil,
      format: nil,
      level: nil,
      metadata: nil,
      metadatafilter: nil,
      rotate: nil
    }

    configure(name, opts, state)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level, :debug)
    metadata = Keyword.get(opts, :metadata, [])
    type = Keyword.get(opts, :type, "elixir")
    host = Keyword.get(opts, :host)

    %{
      name: name,
      host: host,
      level: level,
      metadata: metadata,
      type: type,
    }
  end
end
