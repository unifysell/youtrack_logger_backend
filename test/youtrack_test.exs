defmodule YoutrackTest do
  use ExUnit.Case, async: false

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "youtrack client tests" do
    test "can create issue", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 201, "success")
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
          "test: youtrack client tests\n",
          "can create issue\n"
        )

      assert response.status == 201
    end
  end
end
