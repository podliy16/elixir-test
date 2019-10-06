defmodule Github.Fetcher do

  @moduledoc """
    Fetch data from GitHub.
  """

  @spec get_file(String.t) :: {:error, String.t} | {:ok, String.t}
  def get_file(url) do
    HTTPoison.get(url)
      |> response_handler
  end

  @spec get_repo_info(String.t, String.t) :: {:error, String.t} | {:ok, String.t}
  def get_repo_info(owner, repo_name) do
    url = "https://api.github.com/graphql"
    github_token = Application.get_env(:awesome_elixir, :github_token)

    query = ~s"""
    query {
      repository(owner:"#{owner}", name:"#{repo_name}") {
        stargazers {
          totalCount
        }
        defaultBranchRef {
          target {
            ... on Commit {
              history(first:1) {
                edges {
                  node {
                    committedDate
                  }
                }
              }
            }
          }
        }
      }
    }
    """
    json = Poison.encode!(%{"query" => query})
    fn -> HTTPoison.post(url, json, [{"Authorization", "bearer #{github_token}"}]) end
      |> autoretry(1)
      |> response_handler
  end

  defp autoretry(request_function, attempt) do
    with {:ok, %HTTPoison.Response{status_code: 403}} <- request_function.() do
      next_attempt(request_function, attempt)
    end
  end

  defp next_attempt(request_function, attempt) do
    wait_time = Application.get_env(:awesome_elixir, :retry_sleep)
    Process.sleep(wait_time)
    if attempt < 5 do
      autoretry(request_function, attempt + 1)
    else
      request_function.()
    end
  end

  defp response_handler({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp response_handler({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, "Failed with status code #{status_code} and body #{body}"}
  end

  defp response_handler({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "Failed with error #{reason}"}
  end

end
