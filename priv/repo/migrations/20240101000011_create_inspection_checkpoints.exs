defmodule Koturna.Repo.Migrations.CreateInspectionCheckpoints do
  @moduledoc """
  Creates the inspection_checkpoints table. Individual checklist items within an
  inspection session that must be completed by the inspector.
  """
  use Ecto.Migration

  def change do
    create table(:inspection_checkpoints, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :inspection_session_id,
          references(:inspection_sessions, type: :binary_id, on_delete: :delete_all), null: false

      add :code, :string, null: false
      add :label, :string, null: false
      add :required, :boolean, default: true
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:inspection_checkpoints, [:inspection_session_id])
    create unique_index(:inspection_checkpoints, [:inspection_session_id, :code])
  end
end
