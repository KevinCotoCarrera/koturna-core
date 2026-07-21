defmodule Koturna.Maintenance do
  import Ecto.Query, warn: false
  alias Koturna.Events
  alias Koturna.Inspections.Observation
  alias Koturna.Inspections.ObservationService
  alias Koturna.Maintenance.{MaintenanceTicket, Vendor}
  alias Koturna.Repo

  def list_tickets(org_id) do
    Repo.all(
      from t in MaintenanceTicket,
        where: t.organization_id == ^org_id,
        order_by: [desc: t.inserted_at],
        preload: [:unit, :building, :assigned_vendor, :source_observation]
    )
  end

  def get_ticket!(id) do
    Repo.preload(Repo.get!(MaintenanceTicket, id), [
      :unit,
      :building,
      :assigned_vendor,
      :source_observation
    ])
  end

  def get_ticket(id) do
    Repo.get(MaintenanceTicket, id)
  end

  def create_ticket(attrs \\ %{}) do
    %MaintenanceTicket{}
    |> MaintenanceTicket.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, ticket} ->
        Events.ticket_created(ticket)
        {:ok, ticket}

      error ->
        error
    end
  end

  def create_ticket_from_observation(%Observation{} = observation) do
    if ObservationService.should_create_ticket?(observation) do
      title = "Observation: #{observation.observation_type} — Severity: #{observation.severity}"
      description = observation.summary || ""

      session =
        Koturna.Inspections.InspectionService.get_session(observation.inspection_session_id)

      create_ticket(%{
        title: title,
        description: description,
        priority: map_severity_to_priority(observation.severity),
        organization_id: session.organization_id,
        building_id: session.building_id,
        unit_id: session.unit_id,
        source_observation_id: observation.id
      })
    else
      {:ok, :skipped}
    end
  end

  def update_ticket(%MaintenanceTicket{} = ticket, attrs) do
    ticket
    |> MaintenanceTicket.changeset(attrs)
    |> Repo.update()
  end

  def assign_vendor(%MaintenanceTicket{} = ticket, vendor_id) do
    update_ticket(ticket, %{assigned_vendor_id: vendor_id, status: "assigned"})
  end

  def close_ticket(%MaintenanceTicket{} = ticket, attrs \\ %{}) do
    merged = Map.merge(%{status: "closed", resolved_at: DateTime.utc_now()}, attrs)

    case update_ticket(ticket, merged) do
      {:ok, closed_ticket} ->
        Events.ticket_closed(closed_ticket)
        {:ok, closed_ticket}

      error ->
        error
    end
  end

  def list_vendors(org_id) do
    Repo.all(from v in Vendor, where: v.organization_id == ^org_id, order_by: v.company_name)
  end

  def get_vendor!(id), do: Repo.get!(Vendor, id)

  def create_vendor(attrs \\ %{}) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert()
  end

  def update_vendor(%Vendor{} = vendor, attrs) do
    vendor
    |> Vendor.changeset(attrs)
    |> Repo.update()
  end

  def delete_vendor(%Vendor{} = vendor) do
    Repo.delete(vendor)
  end

  defp map_severity_to_priority("critical"), do: "urgent"
  defp map_severity_to_priority("high"), do: "high"
  defp map_severity_to_priority("medium"), do: "medium"
  defp map_severity_to_priority(_), do: "low"
end
