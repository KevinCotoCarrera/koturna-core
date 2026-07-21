defmodule Koturna.Repo.Migrations.CreateUsers do
  @moduledoc """
  Creates the users table. Platform users who authenticate and perform actions.
  """
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :full_name, :string
      add :status, :string, null: false, default: "active"
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
  end
end
