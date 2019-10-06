defmodule AwesomeElixir.Repo.Migrations.CreateLibs do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :description, :string, null: false

      timestamps()
    end

    create table(:libs) do
      add :link, :string, null: false
      add :name, :string, null: false
      add :description, :string, null: false
      add :stars_count, :integer, null: false
      add :last_commit_at, :naive_datetime, null: false
      add :category_id, references(:categories)

      timestamps()
    end

    create unique_index(:libs, [:link])
    create unique_index(:categories, [:name])

  end
end
