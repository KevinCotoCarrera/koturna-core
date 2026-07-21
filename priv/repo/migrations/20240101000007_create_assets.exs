defmodule Koturna.Repo.Migrations.CreateAssets do
  @moduledoc """
  Creates the assets table. Assets are physical equipment or items within a unit
  that need to be tracked and inspected (ACs, appliances, furniture, etc.).
  """
  use Ecto.Migration

  def change do
    create table(:assets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :unit_id, references(:units, type: :binary_id, on_delete: :delete_all), null: false
      add :category, :string, null: false
      add :name, :string, null: false
      add :manufacturer, :string
      add :serial_number, :string
      add :installed_at, :utc_datetime
      add :expected_lifespan_months, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:assets, [:unit_id])
    create index(:assets, [:category])
    create index(:assets, [:serial_number])

    create constraint(:assets, :category_valid,
             check: "category IN ('ac', 'appliance', 'furniture', 'plant', 'fixture', 'safety')"
           )
  end
end
