defmodule Koturna.Repo.Migrations.CreateBuildings do
  @moduledoc """
  Creates the buildings table. Buildings belong to an organization and contain
  floors and units.
  """
  use Ecto.Migration

  def change do
    create table(:buildings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id), null: false
      add :name, :string, null: false
      add :address, :string
      add :city, :string
      add :country, :string
      add :latitude, :decimal, precision: 10, scale: 7
      add :longitude, :decimal, precision: 10, scale: 7
      add :total_floors, :integer, default: 1
      add :total_units, :integer, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:buildings, [:organization_id])
    create index(:buildings, [:organization_id, :city])
    create index(:buildings, [:organization_id, :name])
  end
end
