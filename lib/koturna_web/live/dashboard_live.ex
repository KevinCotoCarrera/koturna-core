defmodule KoturnaWeb.DashboardLive do
  use KoturnaWeb, :live_view

  import Ecto.Query
  alias Koturna.{Identity, Properties, Inspections, Maintenance, Repo}

  @impl true
  def mount(_params, _session, socket) do
    org = Identity.list_organizations() |> List.first()

    stats =
      if org do
        org_id = org.id

        %{
          total_buildings: org_id |> Properties.list_buildings() |> length(),
          active_inspections:
            Repo.aggregate(
              from(s in Inspections.InspectionSession,
                where: s.organization_id == ^org_id and s.status == "in_progress"
              ),
              :count
            ),
          open_tickets:
            Repo.aggregate(
              from(t in Maintenance.MaintenanceTicket,
                where: t.organization_id == ^org_id and t.status in ~w(open assigned in_progress)
              ),
              :count
            ),
          critical_observations:
            Repo.aggregate(
              from(o in Inspections.Observation,
                join: s in Inspections.InspectionSession,
                on: s.id == o.inspection_session_id,
                where: s.organization_id == ^org_id and o.severity == "critical"
              ),
              :count
            )
        }
      else
        %{
          total_buildings: 0,
          active_inspections: 0,
          open_tickets: 0,
          critical_observations: 0
        }
      end

    socket =
      assign(socket,
        page_title: "Dashboard",
        stats: stats
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="text-2xl font-semibold text-gray-900">Dashboard</h1>
      <p class="mt-1 text-sm text-gray-500">Property portfolio overview</p>

      <!-- Stats grid -->
      <div class="mt-6 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <.stat_card label="Buildings" value={@stats.total_buildings} color="blue" />
        <.stat_card label="Active Inspections" value={@stats.active_inspections} color="green" />
        <.stat_card label="Open Tickets" value={@stats.open_tickets} color="yellow" />
        <.stat_card label="Critical" value={@stats.critical_observations} color="red" />
      </div>

      <!-- Quick links -->
      <div class="mt-10">
        <h2 class="text-lg font-medium text-gray-900">Quick Actions</h2>
        <div class="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-3">
          <.action_card navigate="/inspections" title="Inspections" description="View active and completed inspection sessions" />
          <.action_card navigate="/buildings" title="Buildings" description="Manage your property portfolio" />
          <.action_card navigate="/maintenance" title="Maintenance" description="Track open tickets and assign vendors" />
        </div>
      </div>
    </div>
    """
  end

  defp stat_card(assigns) do
    color_classes = %{
      "blue" => "bg-blue-50 text-blue-700",
      "green" => "bg-green-50 text-green-700",
      "yellow" => "bg-yellow-50 text-yellow-700",
      "red" => "bg-red-50 text-red-700"
    }

    assigns = assign(assigns, :color_class, color_classes[assigns.color])

    ~H"""
    <div class="bg-white overflow-hidden shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <dt class="text-sm font-medium text-gray-500 truncate"><%= @label %></dt>
        <dd class={["mt-1 text-3xl font-semibold", @color_class]}>
          <%= @value %>
        </dd>
      </div>
    </div>
    """
  end

  defp action_card(assigns) do
    ~H"""
    <a href={@navigate} class="block p-6 bg-white rounded-lg shadow hover:shadow-md transition-shadow border border-gray-100">
      <h3 class="text-base font-medium text-gray-900"><%= @title %></h3>
      <p class="mt-2 text-sm text-gray-500"><%= @description %></p>
      <span class="mt-4 inline-flex text-sm font-medium text-blue-600">View &rarr;</span>
    </a>
    """
  end
end
