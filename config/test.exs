import Config

config :koturna, Koturna.Repo,
  username: System.get_env("DB_USERNAME") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOSTNAME") || "localhost",
  database: "koturna_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  ssl: System.get_env("DB_SSL") == "true"

config :koturna, KoturnaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "fSVZGAvEYQXWCwJBMfYdUw7nFeYodWCXiJqx8dyHVXOOTY3yKu+CjPge1YV/V71g",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
