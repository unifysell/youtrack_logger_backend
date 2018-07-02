defmodule YoutrackTest do
  use ExUnit.Case, async: false

  @very_long_message File.read!("test/fixture/very_long_message")

  alias Plug.Conn

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "youtrack client tests" do
    test "can create issue", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        assert "PUT" == conn.method
        assert "/rest/issue" == conn.request_path

        assert ~S() == conn.query_string

        assert {:ok, body, _} = Plug.Conn.read_body(conn)
        assert String.contains?(body, "project=Sandbox")
        assert String.contains?(body, "summary=test-summary")
        assert String.contains?(body, "description=test-description")

        Conn.resp(conn, 201, "success")
      end)

      client =
        Youtrack.client(
          "http://localhost:#{bypass.port}",
          "perm:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        )

      {:ok, response} =
        Youtrack.create_issue(
          client,
          "Sandbox",
          "test-summary",
          "test-description"
        )

      assert response.status == 201
    end

    test "can create issue with long message", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        assert "PUT" == conn.method
        assert "/rest/issue" == conn.request_path
        Conn.resp(conn, 201, "success")
      end)

      client =
        Youtrack.client(
          "http://localhost:#{bypass.port}",
          "perm:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        )

      {:ok, response} =
        Youtrack.create_issue(
          client,
          "Sandbox",
          "Very Large Problem",
          @very_long_message
        )

      assert response.status == 201
    end
  end
end
