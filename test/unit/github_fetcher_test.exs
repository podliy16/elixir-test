defmodule Github.Fetcher.Test do
  use ExUnit.Case, async: false
  import Mock

  test "Get successfull response from github" do
    with_mock HTTPoison, setup_get_response({:ok, %HTTPoison.Response{status_code: 200, body: ""}}) do
      assert Github.Fetcher.get_file("") === {:ok, ""}
    end
  end

  test "Get 404 error from github" do
    with_mock HTTPoison, setup_get_response({:ok, %HTTPoison.Response{status_code: 404}}) do
      assert Github.Fetcher.get_file("") === {:error, "Failed with status code 404"}
    end
  end

  test "Get unknown error from HTTPoison" do
    with_mock HTTPoison, setup_get_response({:error, %HTTPoison.Error{reason: "unknown"}}) do
      assert Github.Fetcher.get_file("") === {:error, "Failed with error unknown"}
    end
  end


  defp setup_get_response(response) do
    [get: fn _ -> response end]
  end


end
