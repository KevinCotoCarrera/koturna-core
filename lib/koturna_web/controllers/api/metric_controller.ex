defmodule KoturnaWeb.API.MetricController do
  use KoturnaWeb, :controller

  alias Koturna.Analytics

  def index(conn, %{"building_id" => building_id} = params) do
    metric_name = params["metric_name"]
    metrics = Analytics.list_metrics(building_id, metric_name)

    json(conn, %{
      data:
        Enum.map(metrics, fn m ->
          %{
            id: m.id,
            metric_name: m.metric_name,
            metric_value: m.metric_value,
            recorded_at: m.recorded_at,
            building_id: m.building_id
          }
        end)
    })
  end
end
