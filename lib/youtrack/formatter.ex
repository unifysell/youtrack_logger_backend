defmodule Youtrack.Formatter do
  @moduledoc """
  Formatting a given data set into string by defined formatting rules.
  """

  import Logger.Formatter, only: [format: 5]

  @doc """
  By given input data, this functions creates a summary string, applying the configured summary format.

  ## Parameters:
    - level
    - message
    - timestamp
    - metadata
    - map - containing summary format and metadata keys

  ## Returns:
    - a string that contains a formatted summary
  """
  @spec generate_summary(atom, binary, tuple, list, map) :: binary
  def generate_summary(level, message, timestamp, metadata, %{
        format_summary: format,
        metadata: keys
      })
      when is_atom(level) and is_binary(message) and is_list(metadata) do
    format
    |> format(level, message, timestamp, take_metadata(metadata, keys))
    |> to_string()
  end

  @doc """
  By given input data, this functions creates a description string, applying the configured summary format.

  ## Parameters:
    - level
    - message
    - timestamp
    - metadata
    - map - containing summary format and metadata keys

  ## Returns:
    - a string that contains a formatted summary
  """
  @spec generate_description(atom, binary, tuple, list, map) :: binary
  def generate_description(level, message, timestamp, metadata, %{
        format_description: format,
        metadata: keys
      })
      when is_atom(level) and is_binary(message) and is_list(metadata) do
    format
    |> format(level, message, timestamp, take_metadata(metadata, keys))
    |> to_string()
  end

  # updates the given metadata
  # the resulting enum only contains the configured keys
  @spec take_metadata(list, any) :: list
  defp take_metadata(metadata, keys) do
    reduced_metadata = reduce_metadata(metadata, keys)

    for {key, value} <- reduced_metadata,
        do: {"'''" <> to_string(key) <> "'''", Kernel.inspect(value) <> "\n"}
  end

  # filters the given metadata by a given filter list
  @spec reduce_metadata(list, any) :: list
  defp reduce_metadata(metadata, keys) when is_nil(keys), do: metadata
  defp reduce_metadata(metadata, :all), do: metadata

  defp reduce_metadata(metadata, keys) do
    keys
    |> Enum.reduce([], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
    |> Enum.reverse()
  end
end
