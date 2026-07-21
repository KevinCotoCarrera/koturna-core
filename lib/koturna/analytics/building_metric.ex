defmodule Koturna.Analytics.BuildingMetric do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "building_metrics" do
    field :metric_name, :string
    field :metric_value, :float
    field :recorded_at, :utc_datetime

    belongs_to :building, Koturna.Properties.Building

    timestamps(type: :utc_datetime)
  end

  def changeset(metric, attrs) do
    metric
    |> cast(attrs, [:metric_name, :metric_value, :recorded_at, :building_id])
    |> validate_required([:metric_name, :metric_value, :recorded_at, :building_id])
    |> foreign_key_constraint(:building_id)
  end
end
