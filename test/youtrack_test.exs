defmodule YoutrackTest do
  use ExUnit.Case, async: false

  describe "youtrack client tests" do
    test "can create issue" do
      client =
        Youtrack.client(
          "https://nepda.myjetbrains.com/youtrack",
          "perm:Y3N0YXVk.ZWxpeGlyIGNsaWVudA==.IhPVDoHQF7bRN45TuhTCM11Cl1nAoA"
        )

      {:ok, response} = Youtrack.create_issue(client, "uapi", "error: PUT https://nepda.myjetbrains.com/youtrack/rest/issue -> 400 (61.818 ms)\n", "2018-05-23 09:48:46.664\npid=<0.696.0> application=tesla module=Tesla.Middleware.Logger function=call/3 file=/home/cstaud/development/unifysell/unifysell_api/deps/tesla/lib/tesla/middleware/logger.ex line=125 \n")

      assert response.status == 201
    end
  end
end
