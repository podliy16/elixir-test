defmodule Github.Updater.Test do
  use AwesomeElixir.DataCase, async: false
  import Mock
  import Ecto.Query
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Ecto.{Category, Lib}
  @moduletag :system
  @moduletag capture_log: true

  setup do
    [
      readme_response: File.read!("test/fixtures/small_readme.md")
    ]
  end

  describe "Github updater" do

    test "Get successfull file from github", %{readme_response: readme_response} do
      mock_function = fn _ -> {:ok, %HTTPoison.Response{status_code: 200, body: readme_response}} end
      with_mock HTTPoison, [:passthrough], [get: mock_function] do
        AwesomeElixir.GithubUpdater.update()

        categories = Repo.all(from c in Category)
        libs = Repo.all(from l in Lib)

        assert length(categories) === 2
        assert length(libs) == 79
      end
    end
  end

end
