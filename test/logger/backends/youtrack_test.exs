defmodule Logger.Backends.YoutrackTest do
  use ExUnit.Case, async: false

  alias Logger.Backends.Youtrack

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :logger,
      :youtrack,
      [
        host: "http://localhost:#{bypass.port}",
        token: "XXX",
        project: "Sandbox",
        level: :warn
      ],
      persistent: true
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

  test "error on invalid init" do
    Application.put_env(
      :logger,
      :youtrack,
      nil
    )

    assert {:error, _} = Youtrack.init({Logger.Backends.Youtrack, :error_log})
  end

  test "can init" do
    Application.put_env(
      :logger,
      :youtrack,
      host: "https://example.com",
      token: "XXX",
      project: "Sandbox",
      level: :warn
    )

    assert {:ok, %Logger.Backends.Youtrack{}} =
             Youtrack.init({Logger.Backends.Youtrack, :error_log})
  end

  test "handle call" do
    assert {:ok, _, %Logger.Backends.Youtrack{}} =
             Youtrack.handle_call(
               {
                 :configure,
                 [
                   format_description: "$date $time\n$metadata\n",
                   format_summary: "$level: $message\n",
                   host: "https://example.com",
                   level: :warn,
                   metadata: nil,
                   project: "Sandbox",
                   token: "XXX"
                 ]
               },
               %Logger.Backends.Youtrack{}
             )
  end

  test "handle event", %{bypass: bypass} do
    Bypass.expect_once(bypass, "PUT", "/rest/issue", fn conn ->
      Plug.Conn.resp(conn, 200, "")
    end)

    assert {:ok, _} =
             Youtrack.handle_event(
               {:error, :any,
                {Logger, "message", {{2018, 6, 14}, {13, 3, 31, 772}},
                 [
                   module: Logger.Backends.YoutrackTest,
                   function: "handle event/1",
                   file:
                     "/home/rutho/projects/youtrack_logger_backend/test/logger/backends/youtrack_test.exs",
                   line: 35
                 ]}},
               %Logger.Backends.Youtrack{
                 format_description: [:date, " ", :time, "\n", :metadata, "\n"],
                 format_summary: [:level, ": ", :message, "\n"],
                 host: "http://localhost:#{bypass.port}",
                 level: :warn,
                 metadata: nil,
                 project: "Sandbox",
                 token: "XXX"
               }
             )
  end
end
