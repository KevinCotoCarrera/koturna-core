defmodule Koturna.Properties.Building do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "buildings" do
    field :name, :string
    field :address, :string
    field :city, :string
    field :country, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :total_floors, :integer, default: 1
    field :total_units, :integer, default: 0

    belongs_to :organization, Koturna.Identity.Organization

    has_many :floors, Koturna.Properties.Floor
    has_many :units, Koturna.Properties.Unit
    has_many :inspection_sessions, Koturna.Inspections.InspectionSession
    has_many :maintenance_tickets, Koturna.Maintenance.MaintenanceTicket
    has_many :building_metrics, Koturna.Analytics.BuildingMetric

    timestamps(type: :utc_datetime)
  end

  def changeset(building, attrs) do
    building
    |> cast(attrs, [
      :name,
      :address,
      :city,
      :country,
      :latitude,
      :longitude,
      :total_floors,
      :total_units,
      :organization_id
    ])
    |> validate_required([:name, :organization_id])
    |> validate_number(:total_floors, greater_than: 0)
    |> validate_number(:total_units, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:organization_id)
  end
end
