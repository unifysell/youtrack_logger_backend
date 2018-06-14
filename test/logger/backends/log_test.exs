defmodule Logger.Backends.LogTest do
  use ExUnit.Case, async: true
  use Plug.Test

  require Logger

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "can log error", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/rest/issue", fn conn ->
      Plug.Conn.resp(conn, 200, "")
    end)

    Application.put_env(
      :logger,
      :youtrack,
      host: "http://localhost:#{bypass.port}",
      token: "XXX",
      project: "Sandbox",
      level: :warn
    )

    Logger.add_backend({Logger.Backends.Youtrack, :error})

    :ok = Logger.error("testing error log")

    Logger.remove_backend({Logger.Backends.Youtrack, :error})

    Application.put_env(
      :logger,
      :youtrack,
      nil
    )
  end
end
