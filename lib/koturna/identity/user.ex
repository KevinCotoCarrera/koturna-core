defmodule Koturna.Identity.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :hashed_password, :string
    field :full_name, :string
    field :status, :string, default: "active"
    field :confirmed_at, :utc_datetime

    has_many :memberships, Koturna.Identity.OrganizationMembership
    has_many :organizations, through: [:memberships, :organization]

    has_many :inspection_sessions, Koturna.Inspections.InspectionSession,
      foreign_key: :inspector_user_id

    timestamps(type: :utc_datetime)
  end

  @valid_statuses ["active", "inactive", "suspended"]

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :hashed_password, :full_name, :status, :confirmed_at])
    |> validate_required([:email, :hashed_password])
    |> validate_inclusion(:status, @valid_statuses)
    |> unique_constraint(:email)
    |> update_change(:email, &String.downcase/1)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :full_name])
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> update_change(:email, &String.downcase/1)
    |> put_hashed_password(attrs["password"] || attrs[:password])
  end

  defp put_hashed_password(changeset, nil), do: changeset

  defp put_hashed_password(changeset, password) do
    put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
  end
end
