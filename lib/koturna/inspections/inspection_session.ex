defmodule Koturna.Inspections.InspectionSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "inspection_sessions" do
    field :inspection_type, :string
    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :status, :string, default: "pending"
    field :route_version, :string

    belongs_to :organization, Koturna.Identity.Organization
    belongs_to :building, Koturna.Properties.Building
    belongs_to :unit, Koturna.Properties.Unit
    belongs_to :inspector, Koturna.Identity.User, foreign_key: :inspector_user_id, references: :id

    has_many :checkpoints, Koturna.Inspections.InspectionCheckpoint
    has_many :observations, Koturna.Inspections.Observation

    timestamps(type: :utc_datetime)
  end

  @valid_types ["checkout", "maintenance", "audit", "move_in", "move_out"]
  @valid_statuses ["pending", "in_progress", "completed", "cancelled"]

  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :inspection_type,
      :started_at,
      :completed_at,
      :status,
      :route_version,
      :organization_id,
      :building_id,
      :unit_id,
      :inspector_user_id
    ])
    |> validate_required([:inspection_type, :organization_id, :building_id, :unit_id])
    |> validate_inclusion(:inspection_type, @valid_types)
    |> validate_inclusion(:status, @valid_statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:building_id)
    |> foreign_key_constraint(:unit_id)
  end
end
