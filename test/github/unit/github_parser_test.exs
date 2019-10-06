defmodule Github.Parser.Test do
  use ExUnit.Case, async: false
  @moduletag :unit

  setup do
    [
      readme_response: File.read!("test/fixtures/readme.md"),
      repo_response: File.read!("test/fixtures/repo.json")
    ]
  end

  describe "Parser readme file" do

    test "assert correct count", %{readme_response: readme_response} do
      parsed_data = get_parsed_data_from_readme_response(readme_response)
      assert length(parsed_data) === 81
    end

    test "assert first category is correct", %{readme_response: readme_response} do
      first_category_with_libs = Enum.at(get_parsed_data_from_readme_response(readme_response), 0)
      assert first_category_with_libs.name === "Actors"
      assert length(first_category_with_libs.libs) === 10
    end

    test "assert last category is correct", %{readme_response: readme_response} do
      last_category_with_libs = Enum.at(get_parsed_data_from_readme_response(readme_response), -1)
      assert last_category_with_libs.name === "YAML"
      assert length(last_category_with_libs.libs) === 4
    end

    test "assert correct coomit date and stars", %{repo_response: repo_response} do
      lib_info = get_parsed_data_from_repo_response(repo_response)
      assert lib_info.stars_count === 171
      assert lib_info.last_commit_at === ~N[2019-10-04 18:48:23]
    end

  end

  defp get_parsed_data_from_readme_response(readme_response) do
    {:ok, parsed_data} = Github.Parser.parse_readme(readme_response)
    parsed_data
  end

  defp get_parsed_data_from_repo_response(repo_response) do
    {:ok, parsed_data} = Github.Parser.parse_repo_response(repo_response)
    parsed_data
  end

end
