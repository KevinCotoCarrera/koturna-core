defmodule Koturna.Repo.Migrations.CreateBuildingMetrics do
  @moduledoc """
  Creates the building_metrics table. Time-series metrics recorded for buildings
  (energy, water usage, occupancy, etc.).
  """
  use Ecto.Migration

  def change do
    create table(:building_metrics, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :building_id, references(:buildings, type: :binary_id, on_delete: :delete_all),
        null: false

      add :metric_name, :string, null: false
      add :metric_value, :float, null: false
      add :recorded_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:building_metrics, [:building_id])
    create index(:building_metrics, [:metric_name])
    create index(:building_metrics, [:recorded_at])
    create index(:building_metrics, [:building_id, :metric_name, :recorded_at])
  end
end
