defmodule KoturnaWeb.BuildingLive.Show do
  use KoturnaWeb, :live_view

  import Ecto.Query
  alias Koturna.{Analytics, Inspections, Properties, Repo}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    building = Properties.get_building(id)
    units = if building, do: Properties.list_units(building.id), else: []
    health_score = if building, do: Analytics.compute_building_health_score(building.id), else: 0

    recent_obs =
      if building do
        Repo.all(
          from o in Inspections.Observation,
            join: s in Inspections.InspectionSession,
            on: s.id == o.inspection_session_id,
            where: s.building_id == ^building.id,
            order_by: [desc: o.inserted_at],
            limit: 10,
            preload: [:inspection_session]
        )
      else
        []
      end

    grade =
      cond do
        health_score >= 90 -> "A"
        health_score >= 75 -> "B"
        health_score >= 60 -> "C"
        health_score >= 40 -> "D"
        true -> "F"
      end

    socket =
      assign(socket,
        page_title: building && building.name,
        building: building,
        units: units,
        health_score: health_score,
        grade: grade,
        recent_obs: recent_obs
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl">
      <div :if={@building == nil} class="mt-12">
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="bldg-not-found" title="Building not found" />
      </div>

      <div :if={@building}>
        <div class="flex items-start justify-between mb-8">
          <div>
            <a href="/buildings" class="text-xs text-neutral-400 hover:text-neutral-600">&larr; All Buildings</a>
            <h1 class="text-2xl font-bold text-neutral-900 mt-1"><%= @building.name %></h1>
            <p class="text-sm text-neutral-400 mt-0.5"><%= @building.address %>, <%= @building.city %>, <%= @building.country %></p>
          </div>
          <.live_component module={KoturnaWeb.Components.DesignSystem.HealthScore} id="bldg-health" score={@health_score} />
        </div>

        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <.stat_box label="Floors" value={@building.total_floors} />
          <.stat_box label="Units" value={@building.total_units} />
          <.stat_box label="Inspections" value={length(@recent_obs)} />
          <.stat_box label="Health" value={"#{@health_score}%"} />
        </div>

        <div class="mb-8">
          <h2 class="text-base font-semibold text-neutral-900 mb-4">Units</h2>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <.unit_card :for={unit <- @units} unit={unit} />
          </div>
          <div :if={@units == []}>
            <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="no-units" title="No units" description="Add units to this building." />
          </div>
        </div>

        <div>
          <h2 class="text-base font-semibold text-neutral-900 mb-4">Recent Observations</h2>
          <div class="space-y-1 bg-white rounded-2xl p-4 shadow-sm border border-neutral-100">
            <.observation_row :for={obs <- @recent_obs} obs={obs} />
          </div>
          <div :if={@recent_obs == []} class="mt-4">
            <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="no-obs" title="No observations yet" />
          </div>
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

  defp unit_card(assigns) do
    risk = Analytics.compute_unit_risk_score(assigns.unit.id)
    grade = if risk > 50, do: "D", else: if(risk > 25, do: "C", else: "B")
    assigns = assign(assigns, :risk_grade, grade)

    ~H"""
    <a href={"/units/#{@unit.id}"} class="stat-card hover:shadow-md transition-shadow cursor-pointer block">
      <div class="flex items-center justify-between mb-2">
        <h3 class="text-sm font-semibold text-neutral-900"><%= @unit.unit_number %></h3>
        <.live_component module={KoturnaWeb.Components.DesignSystem.GradeBadge} id={"ug-#{@unit.id}"} grade={@risk_grade} />
      </div>
      <div class="text-xs text-neutral-400 space-y-0.5">
        <p><%= @unit.unit_type %> · <%= @unit.bedrooms %>bd <%= @unit.bathrooms %>ba</p>
        <p><%= @unit.square_meters %>m² · <%= @unit.occupancy_status %></p>
      </div>
    </a>
    """
  end

  defp observation_row(assigns) do
    ~H"""
    <div class="flex items-center gap-3 py-2.5 border-b border-neutral-50 last:border-0">
      <.live_component module={KoturnaWeb.Components.DesignSystem.RiskPill} id={"or-#{@obs.id}"} severity={@obs.severity} />
      <div class="flex-1 min-w-0">
        <p class="text-sm text-neutral-900 truncate"><%= @obs.summary || @obs.observation_type %></p>
        <p class="text-xs text-neutral-400"><%= @obs.observation_type %></p>
      </div>
    </div>
    """
  end
end
