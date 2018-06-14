defmodule Logger.Backends.LogTest do
  use ExUnit.Case, async: true

  require Logger

  test "can log error" do
    :ok = Logger.error("testing error log")
  end
end
