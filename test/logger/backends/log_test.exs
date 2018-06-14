defmodule Logger.Backends.LogTest do
  use ExUnit.Case, async: false
  use Plug.Test

  require Logger

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :logger,
      :youtrack,
      host: "http://localhost:#{bypass.port}",
      token: "XXX",
      project: "Sandbox",
      level: :warn
    )

    Logger.add_backend({Logger.Backends.Youtrack, :error})

    on_exit(fn ->
      Logger.remove_backend({Logger.Backends.Youtrack, :error})

      Application.put_env(
        :logger,
        :youtrack,
        nil
      )

      :ok
    end)

    {:ok, bypass: bypass}
  end

  test "can log error", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/rest/issue", fn conn ->
      Plug.Conn.resp(conn, 200, "")
    end)

    :ok = Logger.error("testing error log")
  end
end
