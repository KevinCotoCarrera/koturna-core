import Config

config :koturna, KoturnaWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config(:logger, :default_formatter, LoggerJSON, :default_formatter)

config :koturna, Koturna.Mailer,
  adapter: Swoosh.Adapters.Postmark,
  api_key: System.get_env("POSTMARK_API_KEY")
