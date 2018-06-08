defmodule Logger.Backends.YoutrackTest do
  use ExUnit.Case, async: false
  require Logger

  test "can log error" do
    :ok = Logger.error("testing error log")
  end
end
