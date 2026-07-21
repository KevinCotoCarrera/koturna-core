defmodule Koturna.Repo.Migrations.CreateInspectionSessions do
  @moduledoc """
  Creates the inspection_sessions table. Tracks individual inspection sessions
  performed by inspectors within a building unit.
  """
  use Ecto.Migration

  def change do
    create table(:inspection_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id), null: false
      add :building_id, references(:buildings, type: :binary_id), null: false
      add :unit_id, references(:units, type: :binary_id), null: false
      add :inspector_user_id, references(:users, type: :binary_id)
      add :inspection_type, :string, null: false
      add :started_at, :utc_datetime
      add :completed_at, :utc_datetime
      add :status, :string, null: false, default: "pending"
      add :route_version, :string

      timestamps(type: :utc_datetime)
    end

    create index(:inspection_sessions, [:organization_id])
    create index(:inspection_sessions, [:building_id])
    create index(:inspection_sessions, [:unit_id])
    create index(:inspection_sessions, [:inspector_user_id])
    create index(:inspection_sessions, [:status])
    create index(:inspection_sessions, [:organization_id, :status])

    create constraint(:inspection_sessions, :inspection_type_valid,
             check:
               "inspection_type IN ('checkout', 'maintenance', 'audit', 'move_in', 'move_out')"
           )

    create constraint(:inspection_sessions, :status_valid,
             check: "status IN ('pending', 'in_progress', 'completed', 'cancelled')"
           )

    execute "CREATE UNIQUE INDEX idx_sessions_active_per_unit ON inspection_sessions (unit_id) WHERE status = 'in_progress'"
  end
end
