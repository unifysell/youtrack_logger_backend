defmodule Youtrack.Formatter do
  @moduledoc """
  Formatting a given data set into string by defined formatting rules.
  """

  import Logger.Formatter, only: [format: 5]

  def generate_summary(level, message, timestamp, metadata, %{
        format_summary: format,
        metadata: keys
      }) do
    format
    |> format(level, message, timestamp, take_metadata(metadata, keys))
    |> to_string()
  end

  def generate_description(level, message, timestamp, metadata, %{
        format_description: format,
        metadata: keys
      }) do
    format
    |> format(level, message, timestamp, take_metadata(metadata, keys))
    |> to_string()
  end

  defp take_metadata(metadata, keys) when is_nil(keys), do: metadata
  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    reduced_metadata =
      keys
      |> Enum.reduce([], fn key, acc ->
        case Keyword.fetch(metadata, key) do
          {:ok, val} -> [{key, val} | acc]
          :error -> acc
        end
      end)
      |> Enum.reverse()

    for {key, value} <- reduced_metadata,
        do: {"'''" <> to_string(key) <> "'''", to_string(value) <> "\n"}
  end
end
