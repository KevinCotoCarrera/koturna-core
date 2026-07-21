defmodule Koturna.Analytics.ComputeHealthScoresJob do
  use Oban.Worker, queue: :analytics, max_attempts: 3

  alias Koturna.{Analytics, Identity, Properties}

  @impl Oban.Worker
  def perform(_job) do
    Identity.list_organizations()
    |> Enum.each(fn org ->
      Properties.list_buildings(org.id)
      |> Enum.each(fn building ->
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
