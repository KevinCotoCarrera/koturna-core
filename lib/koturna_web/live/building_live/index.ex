defmodule KoturnaWeb.BuildingLive.Index do
  use KoturnaWeb, :live_view

  alias Koturna.{Analytics, Identity, Properties}

  @impl true
  def mount(_params, _session, socket) do
    org = List.first(Identity.list_organizations())
    buildings = if org, do: Properties.list_buildings(org.id), else: []

    scores =
      Map.new(buildings, fn b ->
        score = Analytics.compute_building_health_score(b.id)

        grade =
          cond do
            score >= 90 -> "A"
            score >= 75 -> "B"
            score >= 60 -> "C"
            score >= 40 -> "D"
            true -> "F"
          end

        {b.id, %{score: score, grade: grade}}
      end)

    socket =
      assign(socket,
        page_title: "Buildings",
        buildings: buildings,
        scores: scores
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-2xl font-bold text-neutral-900 mb-1">Buildings</h1>
      <p class="text-sm text-neutral-500 mb-8">Your property portfolio</p>

      <div :if={@buildings == []}>
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="bldg-empty" title="No buildings" description="Add your first building to get started." />
      </div>

      <div :if={@buildings != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <a
          :for={building <- @buildings}
          href={"/buildings/#{building.id}"}
          class="stat-card hover:shadow-md transition-all block"
        >
          <div class="flex items-start justify-between mb-3">
            <h2 class="text-base font-semibold text-neutral-900"><%= building.name %></h2>
            <.live_component module={KoturnaWeb.Components.DesignSystem.GradeBadge} id={"bg-#{building.id}"} grade={Map.get(@scores, building.id, %{grade: "C"}).grade} size="sm" />
          </div>
          <p class="text-xs text-neutral-400"><%= building.address %>, <%= building.city %></p>
          <div class="flex items-center gap-3 mt-3 text-xs text-neutral-500">
            <span><%= building.total_floors %> floors</span>
            <span><%= building.total_units %> units</span>
          </div>
        </a>
      </div>
    </div>
    """
  end
end
