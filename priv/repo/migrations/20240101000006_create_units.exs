defmodule Koturna.Repo.Migrations.CreateUnits do
  @moduledoc """
  Creates the units table. Units represent individual apartments, rooms, or
  commercial spaces within a building.
  """
  use Ecto.Migration

  def change do
    create table(:units, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :building_id, references(:buildings, type: :binary_id, on_delete: :delete_all),
        null: false

      add :floor_id, references(:floors, type: :binary_id, on_delete: :nilify_all)
      add :unit_number, :string, null: false
      add :unit_type, :string
      add :bedrooms, :integer, default: 0
      add :bathrooms, :integer, default: 0
      add :square_meters, :decimal, precision: 10, scale: 2
      add :occupancy_status, :string, default: "vacant"

      timestamps(type: :utc_datetime)
    end

    create index(:units, [:building_id])
    create index(:units, [:floor_id])
    create unique_index(:units, [:building_id, :unit_number])

    create constraint(:units, :unit_type_valid,
             check: "unit_type IN ('studio', 'apartment', 'penthouse', 'commercial')"
           )

    create constraint(:units, :occupancy_status_valid,
             check: "occupancy_status IN ('vacant', 'occupied', 'unknown')"
           )
  end
end
