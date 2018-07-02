defmodule Youtrack do
  @moduledoc """
  A simple module to connect to youtrack REST API and create an issue.
  """
  use Tesla

  @doc """
  Build the default tesla youtrack client for any connection.

  ## Parameters
    - host: the url to a youtrack instance
    - token: a youtrack PERMANENT TOKEN allowing the access to the instance via API

  ## Returns
    - %Tesla.Client{_}
  """
  @spec client(binary, binary) :: Tesla.Client.t()
  def client(host, token) when is_binary(host) and is_binary(token) do
    Tesla.build_client([
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Bearer " <> token},
         {"Accept", "application/json"}
       ]},
      {Tesla.Middleware.BaseUrl, host},
      {Tesla.Middleware.FormUrlencoded, nil}
    ])
  end

  @doc """
  Create an issue with a given summary and description in a given project.
  The connection to the youtrack instance is configured inside the given client.

  ## Parameters:
    - client: %Tesla.Client{_}
    - project: binary
    - summary: binary
    - description: binary

  ## Returns:
    - Tesla.Env.result()
      - {:ok, %Tesla.Env{_}}
      - {:error, any}
  """
  @spec create_issue(Tesla.Client.t(), binary, binary, binary) :: Tesla.Env.result()
  def create_issue(client, project, summary, description)
      when is_binary(project) and is_binary(summary) and is_binary(description) do
    put(
      client,
      "/rest/issue",
      %{project: project, summary: summary, description: description},
      query: []
    )
  end
end
