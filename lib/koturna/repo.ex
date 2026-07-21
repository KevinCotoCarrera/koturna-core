defmodule Koturna.Repo do
  use Ecto.Repo,
    otp_app: :koturna,
    adapter: Ecto.Adapters.Postgres
end
