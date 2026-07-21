defmodule Koturna.Analytics.ComputeHealthScoresJob do
  use Oban.Worker, queue: :analytics, max_attempts: 3

  alias Koturna.{Analytics, Identity, Properties}

  @impl Oban.Worker
  def perform(_job) do
    Enum.each(Identity.list_organizations(), fn org ->
      Enum.each(Properties.list_buildings(org.id), fn building ->
        score = Analytics.compute_building_health_score(building.id)

        Koturna.Analytics.record_metric(%{
          building_id: building.id,
          metric_name: "health_score",
          metric_value: score,
          recorded_at: DateTime.utc_now()
        })
      end)
    end)

    :ok
  end
end
