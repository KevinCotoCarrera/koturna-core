defmodule Koturna.Inspections.Observation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "observations" do
    field :observation_type, :string
    field :severity, :string, default: "info"
    field :confidence, :decimal
    field :location_label, :string
    field :summary, :string
    field :metadata, :map, default: %{}

    belongs_to :inspection_session, Koturna.Inspections.InspectionSession
    belongs_to :checkpoint, Koturna.Inspections.InspectionCheckpoint

    has_many :media_references, Koturna.Inspections.MediaReference

    has_one :maintenance_ticket, Koturna.Maintenance.MaintenanceTicket,
      foreign_key: :source_observation_id

    timestamps(type: :utc_datetime)
  end

  @valid_types [
    "damage",
    "leak_risk",
    "ac_condition",
    "inventory",
    "cleaning",
    "plant_health",
    "safety"
  ]
  @valid_severities ["info", "low", "medium", "high", "critical"]

  def changeset(observation, attrs) do
    observation
    |> cast(attrs, [
      :observation_type,
      :severity,
      :confidence,
      :location_label,
      :summary,
      :metadata,
      :inspection_session_id,
      :checkpoint_id
    ])
    |> validate_required([:observation_type, :severity, :inspection_session_id])
    |> validate_inclusion(:observation_type, @valid_types)
    |> validate_inclusion(:severity, @valid_severities)
    |> validate_number(:confidence, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:inspection_session_id)
  end

  def critical?(observation) do
    observation.severity == "critical"
  end
end
