defmodule Koturna.Identity.OrganizationMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organization_memberships" do
    field :role, :string, default: "inspector"

    belongs_to :user, Koturna.Identity.User
    belongs_to :organization, Koturna.Identity.Organization

    timestamps(type: :utc_datetime)
  end

  @valid_roles ["owner", "manager", "inspector", "vendor"]

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :user_id, :organization_id])
    |> validate_required([:role, :user_id, :organization_id])
    |> validate_inclusion(:role, @valid_roles)
    |> unique_constraint([:user_id, :organization_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:organization_id)
  end
end
