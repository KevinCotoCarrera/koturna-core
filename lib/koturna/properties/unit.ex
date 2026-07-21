defmodule Koturna.Properties.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "units" do
    field :unit_number, :string
    field :unit_type, :string
    field :bedrooms, :integer, default: 0
    field :bathrooms, :integer, default: 0
    field :square_meters, :decimal
    field :occupancy_status, :string, default: "vacant"

    belongs_to :building, Koturna.Properties.Building
    belongs_to :floor, Koturna.Properties.Floor

    has_many :assets, Koturna.Properties.Asset
    has_many :inventory_items, Koturna.Properties.InventoryItem
    has_many :inspection_sessions, Koturna.Inspections.InspectionSession
    has_many :maintenance_tickets, Koturna.Maintenance.MaintenanceTicket

    timestamps(type: :utc_datetime)
  end

  @valid_unit_types ["studio", "apartment", "penthouse", "commercial"]
  @valid_occupancy_statuses ["vacant", "occupied", "unknown"]

  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [
      :unit_number,
      :unit_type,
      :bedrooms,
      :bathrooms,
      :square_meters,
      :occupancy_status,
      :building_id,
      :floor_id
    ])
    |> validate_required([:unit_number, :building_id])
    |> validate_inclusion(:unit_type, @valid_unit_types)
    |> validate_inclusion(:occupancy_status, @valid_occupancy_statuses)
    |> validate_number(:bedrooms, greater_than_or_equal_to: 0)
    |> validate_number(:bathrooms, greater_than_or_equal_to: 0)
    |> unique_constraint([:building_id, :unit_number])
    |> foreign_key_constraint(:building_id)
    |> foreign_key_constraint(:floor_id)
  end
end
