defmodule Koturna.Repo.Migrations.CreateMediaReferences do
  @moduledoc """
  Creates the media_references table. Stores references to photos, videos, and
  other media captured during inspections, linked to observations.
  """
  use Ecto.Migration

  def change do
    create table(:media_references, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :observation_id, references(:observations, type: :binary_id, on_delete: :delete_all),
        null: false

      add :storage_key, :string, null: false
      add :media_type, :string, null: false
      add :checksum, :string
      add :captured_at, :utc_datetime
      add :retained_reason, :string

      timestamps(type: :utc_datetime)
    end

    create index(:media_references, [:observation_id])
    create unique_index(:media_references, [:storage_key])

    create constraint(:media_references, :media_type_valid,
             check: "media_type IN ('image', 'video', 'thermal', 'audio', 'document')"
           )
  end
end
