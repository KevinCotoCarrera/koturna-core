defmodule Koturna.Repo.Migrations.CreateMaintenanceTickets do
  @moduledoc """
  Creates the maintenance_tickets table. Tracks repair and maintenance work
  orders generated from observations or manually created.
  """
  use Ecto.Migration

  def change do
    create table(:maintenance_tickets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id), null: false
      add :building_id, references(:buildings, type: :binary_id)
      add :unit_id, references(:units, type: :binary_id)
      add :source_observation_id, references(:observations, type: :binary_id)
      add :title, :string, null: false
      add :description, :text
      add :priority, :string, default: "medium"
      add :status, :string, default: "open"
      add :estimated_cost_cents, :bigint
      add :actual_cost_cents, :bigint
      add :assigned_vendor_id, references(:vendors, type: :binary_id)
      add :resolved_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:maintenance_tickets, [:organization_id])
    create index(:maintenance_tickets, [:building_id])
    create index(:maintenance_tickets, [:unit_id])
    create index(:maintenance_tickets, [:source_observation_id])
    create index(:maintenance_tickets, [:assigned_vendor_id])
    create index(:maintenance_tickets, [:status])

    create constraint(:maintenance_tickets, :priority_valid,
             check: "priority IN ('low', 'medium', 'high', 'urgent')"
           )

    create constraint(:maintenance_tickets, :status_valid,
             check:
               "status IN ('open', 'assigned', 'in_progress', 'resolved', 'closed', 'cancelled')"
           )

    execute "CREATE INDEX idx_tickets_active ON maintenance_tickets (inserted_at) WHERE status IN ('open', 'assigned')"
  end
end
