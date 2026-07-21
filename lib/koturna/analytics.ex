defmodule Koturna.Analytics do
  import Ecto.Query, warn: false
  alias Koturna.Analytics.BuildingMetric
  alias Koturna.Inspections.Observation
  alias Koturna.Repo

  def record_metric(attrs \\ %{}) do
    %BuildingMetric{}
    |> BuildingMetric.changeset(attrs)
    |> Repo.insert()
  end

  def list_metrics(building_id, metric_name \\ nil) do
    query =
      from m in BuildingMetric,
        where: m.building_id == ^building_id,
        order_by: [desc: m.recorded_at]

    query =
      if metric_name do
        from m in query, where: m.metric_name == ^metric_name
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Computes a building health score (0.0 - 100.0).
  Based on recent critical/high observations per unit, pending tickets, and inspection coverage.
  """
  def compute_building_health_score(nil), do: 0.0

  def compute_building_health_score(building_id) do
    total_units = length(Koturna.Properties.list_units(building_id))

    if total_units == 0 do
      0.0
    else
      recent_observations =
        Repo.all(
          from o in Observation,
            join: s in Koturna.Inspections.InspectionSession,
            on: s.id == o.inspection_session_id,
            where: s.building_id == ^building_id,
            where: o.inserted_at > ago(90, "day")
        )

      critical_count = Enum.count(recent_observations, &(&1.severity in ["critical"]))
      high_count = Enum.count(recent_observations, &(&1.severity in ["high"]))
      medium_count = Enum.count(recent_observations, &(&1.severity in ["medium"]))

      deduction = critical_count * 15.0 + high_count * 8.0 + medium_count * 3.0
      deduction_per_unit = deduction / total_units

      Float.round(max(0.0, 100.0 - deduction_per_unit), 1)
    end
  end

  @doc """
  Computes a risk score for a specific unit (0.0 - 100.0).
  Higher score = higher risk.
  """
  def compute_unit_risk_score(nil), do: 0.0

  def compute_unit_risk_score(unit_id) do
    observations =
      Repo.all(
        from o in Observation,
          join: s in Koturna.Inspections.InspectionSession,
          on: s.id == o.inspection_session_id,
          where: s.unit_id == ^unit_id,
          where: o.inserted_at > ago(180, "day")
      )

    if observations == [] do
      0.0
    else
      critical = Enum.count(observations, &(&1.severity == "critical"))
      high = Enum.count(observations, &(&1.severity == "high"))
      medium = Enum.count(observations, &(&1.severity == "medium"))
      total = length(observations)

      risk = critical * 25.0 + high * 15.0 + medium * 5.0
      risk = risk / total

      Float.round(min(100.0, risk), 1)
    end
  end

  @doc """
  Aggregates daily metrics for a building: counts of inspections, observations, created tickets.
  Stores results as building_metrics.
  """
  def aggregate_daily_metrics(building_id) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    today_start = DateTime.new!(today, ~T[00:00:00])
    yesterday_start = DateTime.new!(yesterday, ~T[00:00:00])

    inspection_count =
      Repo.aggregate(
        from(s in Koturna.Inspections.InspectionSession,
          where: s.building_id == ^building_id,
          where: s.inserted_at >= ^yesterday_start,
          where: s.inserted_at < ^today_start
        ),
        :count
      )

    observation_count =
      Repo.aggregate(
        from(o in Observation,
          join: s in Koturna.Inspections.InspectionSession,
          on: s.id == o.inspection_session_id,
          where: s.building_id == ^building_id,
          where: o.inserted_at >= ^yesterday_start,
          where: o.inserted_at < ^today_start
        ),
        :count
      )

    critical_count =
      Repo.aggregate(
        from(o in Observation,
          join: s in Koturna.Inspections.InspectionSession,
          on: s.id == o.inspection_session_id,
          where: s.building_id == ^building_id,
          where: o.severity == "critical",
          where: o.inserted_at >= ^yesterday_start,
          where: o.inserted_at < ^today_start
        ),
        :count
      )

    health_score = compute_building_health_score(building_id)

    metrics = [
      %{
        building_id: building_id,
        metric_name: "daily_inspections",
        metric_value: inspection_count,
        recorded_at: today_start
      },
      %{
        building_id: building_id,
        metric_name: "daily_observations",
        metric_value: observation_count,
        recorded_at: today_start
      },
      %{
        building_id: building_id,
        metric_name: "daily_critical",
        metric_value: critical_count,
        recorded_at: today_start
      },
      %{
        building_id: building_id,
        metric_name: "health_score",
        metric_value: health_score,
        recorded_at: today_start
      }
    ]

    Enum.each(metrics, fn metric ->
      record_metric(metric)
    end)

    {:ok, metrics}
  end
end
