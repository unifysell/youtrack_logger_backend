defmodule YoutrackLoggerBackendTest do
  use ExUnit.Case, async: false
  require Logger

  @backend {YoutrackLoggerBackend, :test}
  Logger.add_backend(@backend)

  setup do
    :ok 
  end

  test "does not crash if path isn't set" do

    Logger.debug("foo")
    assert 1+1==2
  end

end
