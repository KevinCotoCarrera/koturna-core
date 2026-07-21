defmodule Koturna.Properties.InventoryItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "inventory_items" do
    field :sku, :string
    field :name, :string
    field :expected_quantity, :integer, default: 1

    belongs_to :unit, Koturna.Properties.Unit

    timestamps(type: :utc_datetime)
  end

  def changeset(inventory_item, attrs) do
    inventory_item
    |> cast(attrs, [:sku, :name, :expected_quantity, :unit_id])
    |> validate_required([:name, :unit_id])
    |> validate_number(:expected_quantity, greater_than: 0)
    |> unique_constraint([:unit_id, :sku])
    |> foreign_key_constraint(:unit_id)
  end
end
