defmodule Koturna.Repo.Migrations.CreateFloors do
  @moduledoc """
  Creates the floors table. Each floor belongs to a building and has a unique
  number within that building.
  """
  use Ecto.Migration

  def change do
    create table(:floors, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :building_id, references(:buildings, type: :binary_id, on_delete: :delete_all),
        null: false

      add :number, :integer, null: false
      add :label, :string

      timestamps(type: :utc_datetime)
    end

    create index(:floors, [:building_id])
    create unique_index(:floors, [:building_id, :number])
  end
end
