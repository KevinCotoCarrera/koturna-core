defmodule KoturnaWeb.OperationsLive do
  use KoturnaWeb, :live_view

  import Ecto.Query
  alias Koturna.{Analytics, Identity, Inspections, Maintenance, Properties, Repo}

  @impl true
  def mount(_params, _session, socket) do
    org = List.first(Identity.list_organizations())

    {buildings, stats, queue, events} =
      if org do
        org_id = org.id
        buildings = Properties.list_buildings(org_id)
        stats = load_stats(org_id, buildings)
        queue = load_queue(org_id)
        events = load_events(org_id)
        {buildings, stats, queue, events}
      else
        {[], default_stats(), [], []}
      end

    socket =
      assign(socket,
        page_title: "Operations",
        buildings: buildings,
        stats: stats,
        queue: queue,
        events: events
      )

    {:ok, socket}
  end

  defp load_stats(org_id, buildings) do
    total_units = buildings |> Enum.map(& &1.id) |> Enum.map(fn bid -> length(Properties.list_units(bid)) end) |> Enum.sum()

    health_scores = Enum.map(buildings, fn b -> {b, Analytics.compute_building_health_score(b.id)} end)
    avg_health =
      if buildings != [] do
        scores = Enum.map(health_scores, fn {_, s} -> s end)
        Enum.sum(scores) / length(buildings)
      else
        0
      end

    active =
      Repo.aggregate(
        from(s in Inspections.InspectionSession,
          where: s.organization_id == ^org_id and s.status == "in_progress"
        ),
        :count
      )

    tickets = Maintenance.list_tickets(org_id)
    open_tickets = Enum.count(tickets, &(&1.status in ~w(open assigned in_progress)))
    urgent = Enum.count(tickets, &(&1.priority == "urgent"))

    critical_obs =
      Repo.aggregate(
        from(o in Inspections.Observation,
          join: s in Inspections.InspectionSession,
          on: s.id == o.inspection_session_id,
          where: s.organization_id == ^org_id and o.severity == "critical"
        ),
        :count
      )

    %{
      health_score: Float.round(avg_health, 1),
      total_buildings: length(buildings),
      total_units: total_units,
      active_inspections: active,
      open_tickets: open_tickets,
      urgent_items: urgent,
      critical_observations: critical_obs
    }
  end

  defp load_queue(org_id) do
    observations =
      Repo.all(
        from o in Inspections.Observation,
          join: s in Inspections.InspectionSession,
          on: s.id == o.inspection_session_id,
          where: s.organization_id == ^org_id and o.severity in ~w(high critical),
          order_by: [desc: o.inserted_at],
          limit: 10,
          preload: [inspection_session: [unit: :building]]
      )

    Enum.map(observations, fn o ->
      unit = o.inspection_session.unit
      %{
        building: if(unit && unit.building, do: unit.building.name, else: unit && unit.building_id),
        unit: if(unit, do: unit.unit_number, else: nil),
        summary: o.summary,
        status: o.observation_type,
        time_ago: time_ago(o.inserted_at),
        severity: o.severity,
        id: o.id
      }
    end)
  end

  defp load_events(org_id) do
    tickets =
      Repo.all(
        from t in Maintenance.MaintenanceTicket,
          where: t.organization_id == ^org_id,
          order_by: [desc: t.inserted_at],
          limit: 10,
          preload: [:unit, :building]
      )

    Enum.map(tickets, fn t ->
      %{
        title: t.title,
        description: "#{inspect(t.status)} ticket",
        time: time_ago(t.inserted_at),
        color: ticket_color(t.status)
      }
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-2xl font-bold text-neutral-900">Operations</h1>
          <p class="mt-1 text-sm text-neutral-500">Portfolio overview &amp; next actions</p>
        </div>
        <div class="flex items-center gap-3">
          <.live_component module={KoturnaWeb.Components.DesignSystem.SLABadge} id="sla-main" status="ok" />
          <.live_component module={KoturnaWeb.Components.DesignSystem.HealthScore} id="health-main" score={@stats.health_score} size="lg" />
        </div>
      </div>

      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <.stat_box label="Active Inspections" value={@stats.active_inspections} />
        <.stat_box label="Open Tickets" value={@stats.open_tickets} />
        <.stat_box label="Urgent" value={@stats.urgent_items} />
        <.stat_box label="Critical Obs." value={@stats.critical_observations} />
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-2">
          <h2 class="text-base font-semibold text-neutral-900 mb-4">My Queue</h2>
          <div class="space-y-3">
            <.live_component
              :for={item <- @queue}
              module={KoturnaWeb.Components.DesignSystem.QueueCard}
              id={"queue-#{item.id}"}
              building={item.building}
              unit={item.unit}
              summary={item.summary || ""}
              status={item.status}
              time_ago={item.time_ago}
              severity={item.severity}
              action_label="Review"
              on_action={Phoenix.LiveView.JS.navigate("/inspections?observation=#{item.id}")}
            />
          </div>
          <div :if={@queue == []}>
            <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="queue-empty" title="All clear" description="No items requiring immediate attention." />
          </div>
        </div>

        <div class="insight-panel">
          <h2 class="text-sm font-semibold text-neutral-900 mb-4">Activity</h2>
          <div class="space-y-1">
            <div :for={event <- @events} class="activity-item">
              <div class="flex flex-col items-center">
                <div class={["timeline-dot", event_color(event.color)]}></div>
                <div class="timeline-line flex-1"></div>
              </div>
              <div class="flex-1 min-w-0 pb-4">
                <p class="text-sm font-medium text-neutral-900"><%= event.title %></p>
                <p :if={event.description} class="mt-0.5 text-xs text-neutral-400"><%= event.description %></p>
                <p :if={event.time} class="mt-1 text-xs text-neutral-400"><%= event.time %></p>
              </div>
            </div>
          </div>
          <div :if={@events == []}>
            <p class="text-sm text-neutral-400 py-8 text-center">No recent activity</p>
          </div>
        </div>
      </div>

      <div class="mt-10">
        <h2 class="text-base font-semibold text-neutral-900 mb-4">Portfolio</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <.building_card :for={building <- @buildings} building={building} />
        </div>
      </div>
    </div>
    """
  end

  defp stat_box(assigns) do
    ~H"""
    <div class="stat-card">
      <div class="text-2xl font-bold text-neutral-900"><%= @value %></div>
      <div class="text-xs text-neutral-400 mt-1"><%= @label %></div>
    </div>
    """
  end

  defp building_card(assigns) do
    ~H"""
    <a href={"/buildings/#{@building.id}"} class="stat-card hover:shadow-md transition-shadow">
      <h3 class="text-sm font-semibold text-neutral-900"><%= @building.name %></h3>
      <p class="text-xs text-neutral-400 mt-1"><%= @building.address %>, <%= @building.city %></p>
      <div class="flex items-center gap-4 mt-3 text-xs text-neutral-500">
        <span><%= @building.total_floors %> floors</span>
        <span><%= @building.total_units %> units</span>
      </div>
    </a>
    """
  end

  defp time_ago(nil), do: ""

  defp time_ago(dt) do
    diff = DateTime.diff(DateTime.utc_now(), dt)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(trunc(diff), 60)}m ago"
      diff < 86_400 -> "#{div(trunc(diff), 3600)}h ago"
      true -> "#{div(trunc(diff), 86_400)}d ago"
    end
  end

  defp ticket_color("open"), do: "blue"
  defp ticket_color("assigned"), do: "amber"
  defp ticket_color("in_progress"), do: "amber"
  defp ticket_color("resolved"), do: "green"
  defp ticket_color("closed"), do: "green"
  defp ticket_color(_), do: "neutral"

  defp event_color("green"), do: "bg-emerald-500"
  defp event_color("red"), do: "bg-red-500"
  defp event_color("amber"), do: "bg-amber-500"
  defp event_color("blue"), do: "bg-blue-500"
  defp event_color(_), do: "bg-neutral-300"

  defp default_stats,
    do: %{
      health_score: 0,
      total_buildings: 0,
      total_units: 0,
      active_inspections: 0,
      open_tickets: 0,
      urgent_items: 0,
      critical_observations: 0
    }
end
