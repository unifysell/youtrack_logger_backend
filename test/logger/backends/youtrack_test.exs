defmodule Logger.Backends.YoutrackTest do
  use ExUnit.Case, async: false

  alias Logger.Backends.Youtrack

  test "error on invalid init" do
    Application.put_env(
      :logger,
      :youtrack,
      nil
    )

    {:error, _} = Youtrack.init({Logger.Backends.Youtrack, :error_log})
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

    {:ok, %Logger.Backends.Youtrack{}} = Youtrack.init({Logger.Backends.Youtrack, :error_log})
  end

  test "handle call" do
    {:ok, _, %Logger.Backends.Youtrack{}} =
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
end
