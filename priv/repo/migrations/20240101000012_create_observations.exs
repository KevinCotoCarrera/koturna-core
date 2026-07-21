defmodule Koturna.Repo.Migrations.CreateObservations do
  @moduledoc """
  Creates the observations table. AI-generated or manual observations recorded
  during inspections — issues, findings, or condition notes.
  """
  use Ecto.Migration

  def change do
    create table(:observations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :inspection_session_id, references(:inspection_sessions, type: :binary_id), null: false
      add :checkpoint_id, references(:inspection_checkpoints, type: :binary_id)
      add :observation_type, :string, null: false
      add :severity, :string, null: false, default: "info"
      add :confidence, :decimal
      add :location_label, :string
      add :summary, :text
      add :metadata, :jsonb, default: "{}"

      timestamps(type: :utc_datetime)
    end

    create index(:observations, [:inspection_session_id])
    create index(:observations, [:checkpoint_id])
    create index(:observations, [:observation_type])
    create index(:observations, [:severity])

    execute "CREATE INDEX idx_observations_critical ON observations (inserted_at) WHERE severity = 'critical'"

    create constraint(:observations, :observation_type_valid,
             check:
               "observation_type IN ('damage', 'leak_risk', 'ac_condition', 'inventory', 'cleaning', 'plant_health', 'safety')"
           )

    create constraint(:observations, :severity_valid,
             check: "severity IN ('info', 'low', 'medium', 'high', 'critical')"
           )
  end
end
