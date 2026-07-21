defmodule Koturna.Inspections.InspectionCheckpoint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "inspection_checkpoints" do
    field :code, :string
    field :label, :string
    field :required, :boolean, default: true
    field :completed_at, :utc_datetime

    belongs_to :inspection_session, Koturna.Inspections.InspectionSession

    has_many :observations, Koturna.Inspections.Observation, foreign_key: :checkpoint_id

    timestamps(type: :utc_datetime)
  end

  def changeset(checkpoint, attrs) do
    checkpoint
    |> cast(attrs, [:code, :label, :required, :completed_at, :inspection_session_id])
    |> validate_required([:code, :label, :inspection_session_id])
    |> unique_constraint([:inspection_session_id, :code])
    |> foreign_key_constraint(:inspection_session_id)
  end
end
