defmodule Koturna.Repo.Migrations.CreateOrganizations do
  @moduledoc """
  Creates the organizations table. Each organization represents a customer/property
  management company using the platform.
  """
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :timezone, :string, default: "UTC"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:organizations, [:slug])
  end
end
