defmodule Koturna.Analytics.AggregateDailyMetricsJob do
  use Oban.Worker, queue: :analytics, max_attempts: 3

  alias Koturna.{Analytics, Identity, Properties}

  @impl Oban.Worker
  def perform(_job) do
    Enum.each(Identity.list_organizations(), fn org ->
      Enum.each(Properties.list_buildings(org.id), fn building ->
        Analytics.aggregate_daily_metrics(building.id)
      end)
    end)

    :ok
  end
end
