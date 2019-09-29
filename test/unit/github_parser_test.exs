defmodule Github.Parser.Test do
  use ExUnit.Case, async: false
  @moduletag :unit

  setup do
    [file_response: {:ok, File.read!("test/fixtures/readme.md")}]
  end

  describe "Parser readme file" do

    test "assert correct count", %{file_response: file_response} do
      parsed_data = get_parsed_data_from_file_response(file_response)
      assert length(parsed_data) === 81
    end

    test "assert first category is correct", %{file_response: file_response} do
      first_category_with_libs = Enum.at(get_parsed_data_from_file_response(file_response), 0)
      assert first_category_with_libs.name === "Actors"
      assert length(first_category_with_libs.libs) === 10
    end

    test "assert last category is correct", %{file_response: file_response} do
      last_category_with_libs = Enum.at(get_parsed_data_from_file_response(file_response), -1)
      assert last_category_with_libs.name === "YAML"
      assert length(last_category_with_libs.libs) === 4
    end

    test "return error if file is not present" do
      parser_response = Github.Parser.parse_readme({:error, "some error"})
      assert {:error, _} = parser_response
    end

  end

  defp get_parsed_data_from_file_response(file_response) do
    {:ok, parsed_data} = Github.Parser.parse_readme(file_response)
    parsed_data
  end

end
