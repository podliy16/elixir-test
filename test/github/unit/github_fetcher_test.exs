defmodule Github.Fetcher.Test do
  use ExUnit.Case, async: false
  @moduletag :unit
  import Mock

  test "Get successfull file from github" do
    with_mock HTTPoison, setup_get_response({:ok, %HTTPoison.Response{status_code: 200, body: ""}}) do
      assert Github.Fetcher.get_file("") === {:ok, ""}
    end
  end

  test "Get 404 error from github" do
    with_mock HTTPoison, setup_get_response({:ok, %HTTPoison.Response{status_code: 404}}) do
      assert Github.Fetcher.get_file("") === {:error, "Failed with status code 404 and body "}
    end
  end

  test "Get unknown error from HTTPoison" do
    with_mock HTTPoison, setup_get_response({:error, %HTTPoison.Error{reason: "unknown"}}) do
      assert Github.Fetcher.get_file("") === {:error, "Failed with error unknown"}
    end
  end

  test "Get repo info" do
    :meck.new(HTTPoison)
    :meck.expect(HTTPoison, :post, fn(_, _, _) ->  {:ok, %HTTPoison.Response{status_code: 200, body: ""}} end)

    assert Github.Fetcher.get_repo_info("repo_owner", "repo_name") === {:ok, ""}
    query = get_post_data_from_meck_history(:meck.history(HTTPoison))
    assert query =~ "repo_owner"
    assert query =~ "repo_name"

    :meck.unload()
  end

  test "Autoretry" do
    :meck.new(HTTPoison)
    response = [
      {:ok, %HTTPoison.Response{status_code: 403, body: ""}},
      {:ok, %HTTPoison.Response{status_code: 403, body: ""}},
      {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
    ]
    :meck.expect(HTTPoison, :post, 3, :meck.seq(response))

    assert Github.Fetcher.get_repo_info("repo_owner", "repo_name") === {:ok, ""}
    assert :meck.history(HTTPoison) |> Enum.count === 3

    :meck.unload()
  end

  test "Autoretry out of attemps" do
    :meck.new(HTTPoison)
    response = List.duplicate(
      {:ok, %HTTPoison.Response{status_code: 403, body: "error"}},
    6)
    :meck.expect(HTTPoison, :post, 3, :meck.seq(response))

    assert Github.Fetcher.get_repo_info("repo_owner", "repo_name") === {:error, "Failed with status code 403 and body error"}
    assert length(:meck.history(HTTPoison)) === 6

    :meck.unload()
  end

  defp setup_get_response(response) do
    [get: fn _ -> response end]
  end

  defp get_post_data_from_meck_history(history) do
    [{_, {_, _, [_, query, _]}, _}] = history
    query
  end

end
