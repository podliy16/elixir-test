defmodule AwesomeElixir.Ecto.Lib do
  @moduledoc """
    Provides Libs-related functions and libs schema.
  """

  use Ecto.Schema
  alias AwesomeElixir.Ecto.{Category}
  alias AwesomeElixir.Repo

  @type t :: %__MODULE__{
    description: String.t,
    last_commit_at: NaiveDateTime.t,
    link: String.t,
    name: String.t,
    stars_count: integer
  }

  schema "libs" do
    field :description, :string
    field :last_commit_at, :naive_datetime
    field :link, :string
    field :name, :string
    field :stars_count, :integer

    timestamps()

    belongs_to :category, Category
  end

  @spec get_lib_info(Github.Parser.Lib.t) :: {:error, :notfound} | {:ok, map}
  def get_lib_info(%Github.Parser.Lib{} = lib) do
    [owner, repo_name] = get_owner_and_reponame(lib.link)
    with {:ok, repo_response} <- Github.Fetcher.get_repo_info(owner, repo_name),
      {:ok, lib_info} <- Github.Parser.parse_repo_response(repo_response)
    do
      lib_map = Map.from_struct(lib)
      lib_info_map = Map.from_struct(lib_info)
      {:ok, Map.merge(lib_map, lib_info_map)}
    else
      {:error, :notfound} -> {:error, "Not found repo #{lib.link}"}
      {:error, error_message} -> {:error, error_message}
    end
  end

  @spec upsert!(t) :: t
  def upsert!(lib) do
    Repo.insert!(
      lib,
      on_conflict: [set: [
        description: lib.description,
        last_commit_at: lib.last_commit_at,
        stars_count: lib.stars_count
      ]],
      conflict_target: :link
    )
  end

  defp get_owner_and_reponame(repo_url) do
    repo_url
      |> String.trim_trailing("/")
      |> String.split("/")
      |> Enum.take(-2)
  end

end
