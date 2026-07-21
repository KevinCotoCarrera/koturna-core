defmodule Koturna.Maintenance.Vendor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vendors" do
    field :company_name, :string
    field :service_category, :string
    field :contact_name, :string
    field :phone, :string
    field :email, :string

    belongs_to :organization, Koturna.Identity.Organization

    has_many :assigned_tickets, Koturna.Maintenance.MaintenanceTicket,
      foreign_key: :assigned_vendor_id

    timestamps(type: :utc_datetime)
  end

  @valid_categories [
    "plumbing",
    "electrical",
    "hvac",
    "general",
    "cleaning",
    "landscaping",
    "pest_control",
    "security"
  ]

  def changeset(vendor, attrs) do
    vendor
    |> cast(attrs, [
      :company_name,
      :service_category,
      :contact_name,
      :phone,
      :email,
      :organization_id
    ])
    |> validate_required([:company_name, :organization_id])
    |> validate_inclusion(:service_category, @valid_categories)
    |> foreign_key_constraint(:organization_id)
  end
end
