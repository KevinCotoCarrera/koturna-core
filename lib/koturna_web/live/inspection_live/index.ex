defmodule KoturnaWeb.InspectionLive.Index do
  use KoturnaWeb, :live_view

  alias Koturna.{Identity, Inspections.InspectionService, Properties}

  @impl true
  def mount(_params, _session, socket) do
    org = List.first(Identity.list_organizations())
    sessions = if org, do: InspectionService.list_sessions(org.id), else: []

    socket =
      assign(socket,
        page_title: "Inspections",
        sessions: sessions,
        org_id: org && org.id
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("start_session", %{"unit_id" => unit_id, "type" => type}, socket) do
    params = %{
      organization_id: socket.assigns.org_id,
      unit_id: unit_id,
      building_id: get_building_id(unit_id),
      inspection_type: type
    }

    case InspectionService.create_session(params) do
      {:ok, session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Inspection created")
         |> push_navigate(to: "/inspections/#{session.id}")}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Could not create: #{inspect(changeset.errors)}")}
    end
  end

  defp get_building_id(unit_id) do
    unit = Properties.get_unit(unit_id)
    unit && unit.building_id
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl">
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-2xl font-bold text-neutral-900">Inspections</h1>
          <p class="mt-1 text-sm text-neutral-500">Sessions across all properties</p>
        </div>
        <button phx-click={:new_session} class="btn-primary">New Inspection</button>
      </div>

      <div :if={@sessions == []}>
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="insp-empty" title="No inspections yet" description="Start your first inspection session to track building health." />
      </div>

      <div :if={@sessions != []} class="space-y-3">
        <.live_component
          :for={session <- @sessions}
          module={KoturnaWeb.Components.DesignSystem.WorkflowCard}
          id={"session-#{session.id}"}
          title={"#{session.inspection_type} · #{if session.unit, do: session.unit.unit_number, else: session.unit_id}"}
          subtitle={if session.building, do: session.building.name}
          status={session.status}
          time_ago={time_ago(session.inserted_at)}
          action_label={if session.status == "in_progress", do: "Continue", else: "View"}
          action_url={"/inspections/#{session.id}"}
        />
      </div>
    </div>
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
end
