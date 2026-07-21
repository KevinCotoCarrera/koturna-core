import Config

config :koturna,
  ecto_repos: [Koturna.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :koturna, KoturnaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: KoturnaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Koturna.PubSub,
  live_view: [signing_salt: "kPpggoPg"]

config :koturna, KoturnaWeb.ApiSpec,
  openapi: "3.1.0",
  info: [
    title: "Koturna API",
    version: "1.0.0",
    description: "Building data layer and inspection management API"
  ],
  servers: [
    %{url: "http://localhost:4000", description: "Local"},
    %{url: "https://api.koturna.io", description: "Production"}
  ]

config :koturna, Oban,
  engine: Oban.Engines.Basic,
  repo: Koturna.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 86_400},
    {Oban.Plugins.Cron,
     crontab: [
       {"0 2 * * *", Koturna.Analytics.AggregateDailyMetricsJob},
       {"0 4 * * *", Koturna.Analytics.ComputeHealthScoresJob}
     ]}
  ],
  queues: [
    default: 10,
    analytics: 5,
    maintenance: 5,
    inspections: 10,
    media: 3
  ]

config :koturna, Koturna.Mailer,
  adapter: Swoosh.Adapters.Local,
  from_email: "noreply@koturna.io"

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: [{:system, "AWS_REGION"}, "us-east-1"]

config :ex_aws, :s3,
  scheme: "https://",
  host: [{:system, "S3_HOST"}, "s3.amazonaws.com"],
  region: [{:system, "AWS_REGION"}, "us-east-1"]

config :opentelemetry,
  span_processor: :batch,
  sampler: {:parent_based, root: {:trace_id_ratio_based, 0.1}}

config :koturna, PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: :disabled

config :esbuild,
  version: "0.25.4",
  koturna: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :tailwind,
  version: "4.1.7",
  koturna: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
