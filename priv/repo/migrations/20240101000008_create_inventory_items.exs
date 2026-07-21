defmodule Koturna.Repo.Migrations.CreateInventoryItems do
  @moduledoc """
  Creates the inventory_items table. Tracks expected inventory items within each
  unit (e.g. keys, remotes, manuals).
  """
  use Ecto.Migration

  def change do
    create table(:inventory_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :unit_id, references(:units, type: :binary_id, on_delete: :delete_all), null: false
      add :sku, :string
      add :name, :string, null: false
      add :expected_quantity, :integer, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:inventory_items, [:unit_id])
    create unique_index(:inventory_items, [:unit_id, :sku])
  end
end
