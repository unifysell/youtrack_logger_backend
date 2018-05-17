defmodule YoutrackTest do
  use ExUnit.Case, async: false

  describe "youtrack client tests" do
    test "can create issue" do
      client =
        Youtrack.client(
          "https://nepda.myjetbrains.com/youtrack",
          "perm:Y3N0YXVk.ZWxpeGlyIGNsaWVudA==.IhPVDoHQF7bRN45TuhTCM11Cl1nAoA"
        )

      {:ok, response} = Youtrack.create_issue(client, "sandbox", "mySummary", "myDescription")

      assert response.status == 201
    end
  end
end
