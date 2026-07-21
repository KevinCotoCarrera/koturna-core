defmodule KoturnaWeb.API.TicketController do
  use KoturnaWeb, :controller

  alias Koturna.Maintenance

  action_fallback KoturnaWeb.API.FallbackController

  def index(conn, %{"organization_id" => org_id}) do
    tickets = Maintenance.list_tickets(org_id)
    render(conn, :index, tickets: tickets)
  end

  def show(conn, %{"id" => id}) do
    ticket = Maintenance.get_ticket!(id)
    render(conn, :show, ticket: ticket)
  end

  def create(conn, %{"ticket" => ticket_params}) do
    with {:ok, ticket} <- Maintenance.create_ticket(ticket_params) do
      conn
      |> put_status(:created)
      |> render(:show, ticket: ticket)
    end
  end

  def update(conn, %{"id" => id, "ticket" => ticket_params}) do
    ticket = Maintenance.get_ticket!(id)

    with {:ok, ticket} <- Maintenance.update_ticket(ticket, ticket_params) do
      render(conn, :show, ticket: ticket)
    end
  end

  def assign(conn, %{"id" => id, "vendor_id" => vendor_id}) do
    ticket = Maintenance.get_ticket!(id)

    with {:ok, ticket} <- Maintenance.assign_vendor(ticket, vendor_id) do
      render(conn, :show, ticket: ticket)
    end
  end

  def close(conn, %{"id" => id} = params) do
    ticket = Maintenance.get_ticket!(id)
    attrs = Map.take(params, ["actual_cost_cents"])

    with {:ok, ticket} <- Maintenance.close_ticket(ticket, attrs) do
      render(conn, :show, ticket: ticket)
    end
  end

  def render(:index, assigns) do
    %{data: for(t <- assigns.tickets, do: data(t))}
  end

  def render(:show, assigns) do
    %{data: data(assigns.ticket)}
  end

  defp data(ticket) do
    %{
      id: ticket.id,
      title: ticket.title,
      description: ticket.description,
      priority: ticket.priority,
      status: ticket.status,
      estimated_cost_cents: ticket.estimated_cost_cents,
      actual_cost_cents: ticket.actual_cost_cents,
      organization_id: ticket.organization_id,
      building_id: ticket.building_id,
      unit_id: ticket.unit_id,
      source_observation_id: ticket.source_observation_id,
      assigned_vendor_id: ticket.assigned_vendor_id
    }
  end
end
