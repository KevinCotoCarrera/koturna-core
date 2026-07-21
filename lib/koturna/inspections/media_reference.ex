defmodule Koturna.Inspections.MediaReference do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "media_references" do
    field :storage_key, :string
    field :media_type, :string
    field :checksum, :string
    field :captured_at, :utc_datetime
    field :retained_reason, :string

    belongs_to :observation, Koturna.Inspections.Observation

    timestamps(type: :utc_datetime)
  end

  @valid_media_types ["image", "video", "thermal", "audio", "document"]

  def changeset(media_ref, attrs) do
    media_ref
    |> cast(attrs, [
      :storage_key,
      :media_type,
      :checksum,
      :captured_at,
      :retained_reason,
      :observation_id
    ])
    |> validate_required([:storage_key, :media_type, :observation_id])
    |> validate_inclusion(:media_type, @valid_media_types)
    |> unique_constraint(:storage_key)
    |> foreign_key_constraint(:observation_id)
  end
end
