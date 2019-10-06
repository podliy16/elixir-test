defmodule Lib.Test do
  use AwesomeElixir.DataCase, async: false
  import Ecto.Query
  alias AwesomeElixir.Ecto.Lib
  alias AwesomeElixir.Repo
  @moduletag :system

  describe "Lib test" do

    test "Test upsert changes description" do
      lib = %Lib{
        description: "description",
        last_commit_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        link: "link",
        name: "name",
        stars_count: 100
      }
      Lib.upsert!(lib)
      %{lib | description: "new description"} |> Lib.upsert!

      [lib_from_db] = Repo.all(from l in Lib)
      assert lib_from_db.description === "new description"
    end

    test "Test getting lib from github" do
      lib = AwesomeElixir.Factory.build_parser_lib("https://github.com/doomspork/hydra")

      {:ok, %{stars_count: stars_count, last_commit_at: last_commit_at}} = Lib.get_lib_info(lib)
      assert stars_count > 0
      assert last_commit_at > ~N[2016-02-15 00:00:00]
    end

    test "Test not found lib from github" do
      lib = AwesomeElixir.Factory.build_parser_lib("https://github.com/spawnproc/bpe")

      assert {:error, "Not found repo https://github.com/spawnproc/bpe"} == Lib.get_lib_info(lib)
    end

  end

end
