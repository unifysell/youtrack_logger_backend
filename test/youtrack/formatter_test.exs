defmodule Youtrack.FormatterTest do
  use ExUnit.Case, async: false

  alias Youtrack.Formatter

  test "generate summary" do
    assert "error: message\n" ==
             Formatter.generate_summary(
               :error,
               "message",
               {{2018, 6, 14}, {13, 3, 31, 772}},
               [
                 module: Logger.Backends.YoutrackTest,
                 function: "handle event/1",
                 file:
                   "/home/rutho/projects/youtrack_logger_backend/test/logger/backends/youtrack_test.exs",
                 line: 35
               ],
               %{format_summary: [:level, ": ", :message, "\n"], metadata: nil}
             )
  end

  test "generate description" do
    description =
      Formatter.generate_description(
        :error,
        "testing error log",
        {{2018, 6, 14}, {14, 21, 34, 459}},
        [
          pid: "0.305.0",
          module: Logger.Backends.LogTest,
          function: "generate description/1",
          file:
            "/home/rutho/projects/youtrack_logger_backend/test/logger/backends/formatter_test.exs",
          line: 41
        ],
        %{
          format_description: [:date, " ", :time, "\n", :metadata, "\n"],
          metadata: nil
        }
      )

    assert String.match?(
             description,
             ~r/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\.\d\d\d\n/
           )

    assert String.match?(
             description,
             ~r/.*\npid=\d\.\d\d\d\.\d/
           )

    assert String.contains?(description, "module=Logger.Backends.LogTest")
    assert String.contains?(description, "function=generate description/1")

    assert String.contains?(
             description,
             "file=/home/rutho/projects/youtrack_logger_backend/test/logger/backends/formatter_test.exs"
           )

    assert String.contains?(description, "line=41")
  end
end
