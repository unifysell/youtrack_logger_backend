defmodule Youtrack do
  @moduledoc """
  Module to connect to youtrack REST API
  """

  use Tesla

  def client(host, token) when is_binary(host) and is_binary(token) do
    Tesla.build_client([
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Bearer " <> token},
         {"Content-Type", "application/json"},
         {"Accept", "application/json"}
       ]},
      {Tesla.Middleware.BaseUrl, host},
      #  {Tesla.Middleware.Timeout, timeout: 3_000},
      {Tesla.Middleware.JSON, engine: Poison}
    ])
  end

  def create_issue(client, project, summary, description)
      when is_binary(project) and is_binary(summary) and is_binary(description) do
    put(
      client,
      "/rest/issue",
      "",
      query: [project: project, summary: summary, description: description]
    )
  end
end
