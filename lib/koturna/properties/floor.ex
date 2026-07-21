defmodule Koturna.Properties.Floor do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "floors" do
    field :number, :integer
    field :label, :string

    belongs_to :building, Koturna.Properties.Building

    has_many :units, Koturna.Properties.Unit

    timestamps(type: :utc_datetime)
  end

  def changeset(floor, attrs) do
    floor
    |> cast(attrs, [:number, :label, :building_id])
    |> validate_required([:number, :building_id])
    |> unique_constraint([:building_id, :number])
    |> foreign_key_constraint(:building_id)
  end
end
