defmodule Koturna.Analytics.AggregateDailyMetricsJob do
  use Oban.Worker, queue: :analytics, max_attempts: 3

  alias Koturna.{Analytics, Identity, Properties}

  @impl Oban.Worker
  def perform(_job) do
    Identity.list_organizations()
    |> Enum.each(fn org ->
      Properties.list_buildings(org.id)
      |> Enum.each(fn building ->
        Analytics.aggregate_daily_metrics(building.id)
      end)
    end)

    :ok
  end
end
