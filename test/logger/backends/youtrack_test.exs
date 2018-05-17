defmodule Logger.Backends.YoutrackTest do
  use ExUnit.Case, async: false
  require Logger

  setup do
    :ok
  end

  test "can log debug" do
    Logger.error("Hi this is ERROR")
    #    Logger.debug("Hi this is DEBUG")
    #    Logger.info("Hi this is INFO")
    #    Logger.warn("Hi this is WARN")
  end
end
