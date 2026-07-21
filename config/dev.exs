import Config

database_url = System.get_env("DATABASE_URL")

if database_url do
  config :koturna, Koturna.Repo,
    url: database_url,
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10,
    ssl: true
else
  config :koturna, Koturna.Repo,
    username: System.get_env("DB_USERNAME") || "postgres",
    password: System.get_env("DB_PASSWORD") || "postgres",
    hostname: System.get_env("DB_HOSTNAME") || "localhost",
    database: System.get_env("DB_NAME") || "koturna_dev",
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10,
    ssl: System.get_env("DB_SSL") == "true"
end

config :koturna, KoturnaWeb.Endpoint,
  http: [
    ip: {127, 0, 0, 1},
    port: String.to_integer(System.get_env("PORT") || "4000"),
    http_1_options: [max_header_length: 16_384]
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "06ayHWPDhQNHicNxBychosMQwhXrVKrnR75otXlIKbPt97873Ei/8BPVh8XeoYJP",
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "06ayHWPDhQNHicNxBychosMQwhXrVKrnR75otXlIKbPt97873Ei/8BPVh8XeoYJP",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:koturna, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:koturna, ~w(--watch)]}
  ]

config :koturna, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :koturna, Oban,
  queues: [default: 5, analytics: 2, maintenance: 2, inspections: 5, media: 2]

config :koturna, Koturna.Mailer, adapter: Swoosh.Adapters.Local
