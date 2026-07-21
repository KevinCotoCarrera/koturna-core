defmodule KoturnaWeb.MaintenanceLive.Index do
  use KoturnaWeb, :live_view

  alias Koturna.{Identity, Maintenance}

  @impl true
  def mount(_params, _session, socket) do
    org = Identity.list_organizations() |> List.first()
    tickets = if org, do: Maintenance.list_tickets(org.id), else: []
    vendors = if org, do: Maintenance.list_vendors(org.id), else: []

    grouped = Enum.group_by(tickets, & &1.status)

    socket =
      assign(socket,
        page_title: "Maintenance",
        tickets: tickets,
        vendors: vendors,
        grouped: grouped,
        org_id: org && org.id,
        show_vendor_assign: nil,
        statuses: ~w(open assigned in_progress resolved closed)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("move_ticket", %{"id" => id, "to" => to_status}, socket) do
    ticket = Enum.find(socket.assigns.tickets, &(&1.id == id))

    if ticket && valid_transition?(ticket.status, to_status, ticket) do
      attrs = %{"status" => to_status}

      attrs =
        if to_status in ~w(resolved closed),
          do: Map.put(attrs, "resolved_at", DateTime.utc_now()),
          else: attrs

      Maintenance.update_ticket(ticket, attrs)
      {:noreply, reload(socket)}
    else
      reason = transition_error(ticket.status, to_status, ticket)
      {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("assign_vendor", %{"ticket_id" => tid, "vendor_id" => vid}, socket) do
    ticket = Enum.find(socket.assigns.tickets, &(&1.id == tid))
    Maintenance.assign_vendor(ticket, vid)
    {:noreply, assign(socket, :show_vendor_assign, nil) |> reload()}
  end

  def handle_event("show_vendor_assign", %{"id" => id}, socket) do
    {:noreply, assign(socket, :show_vendor_assign, id)}
  end

  def handle_event("hide_vendor_assign", _, socket) do
    {:noreply, assign(socket, :show_vendor_assign, nil)}
  end

  defp valid_transition?("open", "assigned", _), do: true
  defp valid_transition?("open", "cancelled", _), do: true
  defp valid_transition?("assigned", "in_progress", _), do: true
  defp valid_transition?("assigned", "cancelled", _), do: true
  defp valid_transition?("in_progress", "resolved", _), do: true
  defp valid_transition?("resolved", "closed", _), do: true
  defp valid_transition?(_, _, _), do: false

  defp transition_error(_s, "open", _), do: nil

  defp transition_error(_, "assigned", t),
    do:
      if(is_nil(t.assigned_vendor_id),
        do: "Cannot move to Assigned: vendor assignment is missing.",
        else: nil
      )

  defp transition_error(_, _, _), do: "Cannot move: invalid state transition."

  defp reload(socket) do
    org_id = socket.assigns.org_id
    tickets = Maintenance.list_tickets(org_id)
    assign(socket, tickets: tickets, grouped: Enum.group_by(tickets, & &1.status))
  end

  defp time_ago(nil), do: ""

  defp time_ago(dt) do
    diff = DateTime.diff(DateTime.utc_now(), dt)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(trunc(diff), 60)}m"
      diff < 86400 -> "#{div(trunc(diff), 3600)}h"
      true -> "#{div(trunc(diff), 86400)}d"
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-2xl font-bold text-neutral-900">Maintenance</h1>
          <p class="mt-1 text-sm text-neutral-500"><%= length(@tickets) %> total tickets</p>
        </div>
      </div>

      <div :if={@tickets == []}>
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="mt-empty" title="No tickets" description="All maintenance requests will appear here." />
      </div>

      <div :if={@tickets != []} class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4 overflow-x-auto min-h-[60vh]">
        <div :for={status <- @statuses} class="kanban-column">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-sm font-semibold text-neutral-700"><%= String.capitalize(status) %></h3>
            <span class="text-xs text-neutral-400 bg-white rounded-full px-2 py-0.5"><%= length(Map.get(@grouped, status, [])) %></span>
          </div>
          <div class="space-y-3">
            <.ticket_card
              :for={ticket <- Map.get(@grouped, status, [])}
              ticket={ticket}
              vendors={@vendors}
              show_assign={@show_vendor_assign == ticket.id}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp ticket_card(assigns) do
    ~H"""
    <div class="bg-white rounded-xl p-4 shadow-sm border border-neutral-100 hover:shadow-md transition-shadow">
      <div class="flex items-start justify-between gap-2 mb-2">
        <h4 class="text-sm font-semibold text-neutral-900 leading-snug line-clamp-2"><%= @ticket.title %></h4>
        <.live_component module={KoturnaWeb.Components.DesignSystem.RiskPill} id={"tp-#{@ticket.id}"} severity={@ticket.priority} />
      </div>
      <div class="text-xs text-neutral-400 space-y-0.5 mb-3">
        <p :if={@ticket.unit}><%= @ticket.unit.unit_number %></p>
        <p :if={@ticket.assigned_vendor}><%= @ticket.assigned_vendor.company_name %></p>
        <p><%= time_ago(@ticket.updated_at) %></p>
      </div>
      <div class="flex items-center gap-2">
        <button :if={@ticket.status == "open"} phx-click="move_ticket" phx-value-id={@ticket.id} phx-value-to="assigned" class="btn-primary text-[11px] px-2.5 py-1">Assign</button>
        <button :if={@ticket.status == "assigned"} phx-click="move_ticket" phx-value-id={@ticket.id} phx-value-to="in_progress" class="btn-primary text-[11px] px-2.5 py-1">Start</button>
        <button :if={@ticket.status == "in_progress"} phx-click="move_ticket" phx-value-id={@ticket.id} phx-value-to="resolved" class="btn-primary text-[11px] px-2.5 py-1">Resolve</button>
        <button :if={@ticket.status == "resolved"} phx-click="move_ticket" phx-value-id={@ticket.id} phx-value-to="closed" class="btn-primary text-[11px] px-2.5 py-1">Close</button>
        <button :if={@ticket.status in ~w(open assigned) and @show_assign != @ticket.id} phx-click="show_vendor_assign" phx-value-id={@ticket.id} class="btn-ghost text-[11px] px-2 py-1">Vendor</button>
      </div>
      <div :if={@show_assign} class="mt-3 pt-3 border-t border-neutral-100">
        <select phx-change="assign_vendor" phx-value-ticket_id={@ticket.id} class="observation-input text-xs py-2">
          <option value="">Select vendor…</option>
          <option :for={v <- @vendors} value={v.id}><%= v.company_name %></option>
        </select>
        <button phx-click="hide_vendor_assign" class="text-xs text-neutral-400 mt-1 hover:text-neutral-600">Cancel</button>
      </div>
    </div>
    """
  end
end
