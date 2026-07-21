defmodule Koturna.Repo.Migrations.CreateVendors do
  @moduledoc """
  Creates the vendors table. External service providers that can be assigned to
  maintenance tickets.
  """
  use Ecto.Migration

  def change do
    create table(:vendors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :organization_id, references(:organizations, type: :binary_id), null: false
      add :company_name, :string, null: false
      add :service_category, :string
      add :contact_name, :string
      add :phone, :string
      add :email, :string

      timestamps(type: :utc_datetime)
    end

    create index(:vendors, [:organization_id])
    create index(:vendors, [:service_category])

    create constraint(:vendors, :service_category_valid,
             check:
               "service_category IN ('plumbing', 'electrical', 'hvac', 'general', 'cleaning', 'landscaping', 'pest_control', 'security')"
           )
  end
end
