defmodule Koturna.Maintenance.MaintenanceTicket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "maintenance_tickets" do
    field :title, :string
    field :description, :string
    field :priority, :string, default: "medium"
    field :status, :string, default: "open"
    field :estimated_cost_cents, :integer
    field :actual_cost_cents, :integer
    field :resolved_at, :utc_datetime

    belongs_to :organization, Koturna.Identity.Organization
    belongs_to :building, Koturna.Properties.Building
    belongs_to :unit, Koturna.Properties.Unit
    belongs_to :source_observation, Koturna.Inspections.Observation
    belongs_to :assigned_vendor, Koturna.Maintenance.Vendor

    timestamps(type: :utc_datetime)
  end

  @valid_priorities ["low", "medium", "high", "urgent"]
  @valid_statuses ["open", "assigned", "in_progress", "resolved", "closed", "cancelled"]

  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [
      :title,
      :description,
      :priority,
      :status,
      :estimated_cost_cents,
      :actual_cost_cents,
      :resolved_at,
      :organization_id,
      :building_id,
      :unit_id,
      :source_observation_id,
      :assigned_vendor_id
    ])
    |> validate_required([:title, :organization_id])
    |> validate_inclusion(:priority, @valid_priorities)
    |> validate_inclusion(:status, @valid_statuses)
    |> foreign_key_constraint(:organization_id)
  end
end
