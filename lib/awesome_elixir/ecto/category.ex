defmodule AwesomeElixir.Ecto.Category do
  @moduledoc """
    Provides Category-related functions and categories schema.
  """

  use Ecto.Schema
  require Logger
  alias AwesomeElixir.Ecto.{Category, Lib}
  alias AwesomeElixir.Repo

  @type t :: %__MODULE__{
    description: String.t,
    name: String.t
  }

  schema "categories" do
    field :description, :string
    field :name, :string

    timestamps()

    has_many :libs, Lib, on_delete: :delete_all
  end

  @spec update_category_with_libs(Github.Parser.CategoryWithLibs.t) :: :ok
  def update_category_with_libs(%Github.Parser.CategoryWithLibs{} = category_with_libs) do
    category = upsert!(%Category{
      name: category_with_libs.name, description: category_with_libs.description
    })
    libs_with_info = category_with_libs.libs
      |> Enum.map(&Task.async(fn -> Lib.get_lib_info(&1) end))
      |> Enum.map(&Task.await(&1, 120_000))

    for lib_with_info <- libs_with_info do
      case lib_with_info do
        {:error, error_message} -> Logger.error(error_message)
        {:ok, lib} -> Ecto.build_assoc(category, :libs, lib) |> Lib.upsert!
      end
    end

    :ok
  end

  @spec upsert!(t) :: t
  defp upsert!(category) do
    Repo.insert!(
      category,
      on_conflict: [set: [description: category.description]],
      conflict_target: :name
    )
  end

end
