defmodule Category.Test do
  use AwesomeElixir.DataCase, async: false
  import Ecto.Query
  alias AwesomeElixir.Ecto.{Category}
  alias AwesomeElixir.Repo
  @moduletag :system
  @moduletag capture_log: true

  describe "Category test" do

    test "Test upsert changes description" do
      category = AwesomeElixir.Factory.build_parser_category([])
      Category.update_category_with_libs(category)
      %{category | description: "new description"} |> Category.update_category_with_libs

      [category_from_db] = Repo.all(from c in Category)
      assert category_from_db.description === "new description"
    end

    test "Test libs insertion" do
      category_with_libs = AwesomeElixir.Factory.build_parser_category([
        AwesomeElixir.Factory.build_parser_lib("https://github.com/dalmatinerdb/dflow"),
        AwesomeElixir.Factory.build_parser_lib("https://github.com/sasa1977/exactor"),
        AwesomeElixir.Factory.build_parser_lib("https://github.com/awetzel/exos"),
        AwesomeElixir.Factory.build_parser_lib("https://github.com/antonmi/flowex")
      ])

      Category.update_category_with_libs(category_with_libs)
      [category_with_libs_from_db] = AwesomeElixir.Repo.all(from c in Category, preload: :libs)

      assert length(category_with_libs_from_db.libs) === length(category_with_libs.libs)
    end

    test "Test libs with error not inserted" do
      category_with_libs = AwesomeElixir.Factory.build_parser_category([
        AwesomeElixir.Factory.build_parser_lib("https://github.com/dalmatinerdb/dflow"),
        AwesomeElixir.Factory.build_parser_lib("https://github.com/spawnproc/bpe")
      ])

      Category.update_category_with_libs(category_with_libs)
      [category_with_libs_from_db] = AwesomeElixir.Repo.all(from c in Category, preload: :libs)

      assert length(category_with_libs_from_db.libs) === 1
    end

  end

end
