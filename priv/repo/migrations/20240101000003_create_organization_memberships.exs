defmodule Koturna.Repo.Migrations.CreateOrganizationMemberships do
  @moduledoc """
  Creates the organization_memberships join table linking users to organizations
  with role-based access control.
  """
  use Ecto.Migration

  def change do
    create table(:organization_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :organization_id, references(:organizations, type: :binary_id), null: false
      add :role, :string, null: false, default: "inspector"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organization_memberships, [:user_id, :organization_id])
    create index(:organization_memberships, [:user_id])
    create index(:organization_memberships, [:organization_id])

    create constraint(:organization_memberships, :role_valid,
             check: "role IN ('owner', 'manager', 'inspector', 'vendor')"
           )
  end
end
