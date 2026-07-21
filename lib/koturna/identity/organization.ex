defmodule Koturna.Identity.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :timezone, :string, default: "UTC"

    has_many :memberships, Koturna.Identity.OrganizationMembership
    has_many :users, through: [:memberships, :user]
    has_many :buildings, Koturna.Properties.Building
    has_many :inspection_sessions, Koturna.Inspections.InspectionSession
    has_many :maintenance_tickets, Koturna.Maintenance.MaintenanceTicket
    has_many :vendors, Koturna.Maintenance.Vendor

    timestamps(type: :utc_datetime)
  end

  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug, :timezone])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> update_change(:slug, &String.downcase/1)
  end
end
