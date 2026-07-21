defmodule Koturna.Properties.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "assets" do
    field :category, :string
    field :name, :string
    field :manufacturer, :string
    field :serial_number, :string
    field :installed_at, :utc_datetime
    field :expected_lifespan_months, :integer

    belongs_to :unit, Koturna.Properties.Unit

    timestamps(type: :utc_datetime)
  end

  @valid_categories ["ac", "appliance", "furniture", "plant", "fixture", "safety"]

  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [
      :category,
      :name,
      :manufacturer,
      :serial_number,
      :installed_at,
      :expected_lifespan_months,
      :unit_id
    ])
    |> validate_required([:category, :name, :unit_id])
    |> validate_inclusion(:category, @valid_categories)
    |> foreign_key_constraint(:unit_id)
  end
end
