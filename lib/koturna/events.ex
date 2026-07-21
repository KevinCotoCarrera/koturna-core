defmodule Koturna.Events do
  alias Phoenix.PubSub

  @topic "koturna:events"

  def subscribe do
    PubSub.subscribe(Koturna.PubSub, @topic)
  end

  def broadcast(event_name, payload) do
    message = %{
      event: event_name,
      payload: payload,
      metadata: %{
        timestamp: DateTime.to_iso8601(DateTime.utc_now()),
        source: "koturna"
      }
    }

    PubSub.broadcast(Koturna.PubSub, @topic, message)
    :ok
  end

  def inspection_started(session) do
    broadcast("inspection.started", %{
      inspection_session_id: session.id,
      organization_id: session.organization_id,
      building_id: session.building_id,
      unit_id: session.unit_id,
      inspector_user_id: session.inspector_user_id,
      inspection_type: session.inspection_type
    })
  end

  def inspection_completed(session) do
    critical_count =
      Enum.count(
        Koturna.Inspections.InspectionService.list_observations(session.id),
        &(&1.severity == "critical")
      )

    broadcast("inspection.completed", %{
      inspection_session_id: session.id,
      organization_id: session.organization_id,
      unit_id: session.unit_id,
      completed_at: session.completed_at,
      total_observations:
        length(Koturna.Inspections.InspectionService.list_observations(session.id)),
      critical_observations: critical_count
    })
  end

  def observation_created(observation) do
    broadcast("observation.created", %{
      observation_id: observation.id,
      inspection_session_id: observation.inspection_session_id,
      observation_type: observation.observation_type,
      severity: observation.severity,
      unit_id: observation.inspection_session_id
    })
  end

  def observation_critical(observation) do
    session = Koturna.Inspections.InspectionService.get_session(observation.inspection_session_id)

    broadcast("observation.critical", %{
      observation_id: observation.id,
      inspection_session_id: observation.inspection_session_id,
      observation_type: observation.observation_type,
      unit_id: session.unit_id,
      building_id: session.building_id,
      summary: observation.summary
    })

    Koturna.Maintenance.create_ticket_from_observation(observation)
  end

  def ticket_created(ticket) do
    broadcast("ticket.created", %{
      ticket_id: ticket.id,
      organization_id: ticket.organization_id,
      building_id: ticket.building_id,
      unit_id: ticket.unit_id,
      priority: ticket.priority,
      source_observation_id: ticket.source_observation_id
    })
  end

  def ticket_closed(ticket) do
    broadcast("ticket.closed", %{
      ticket_id: ticket.id,
      organization_id: ticket.organization_id,
      actual_cost_cents: ticket.actual_cost_cents,
      resolved_at: ticket.resolved_at
    })
  end
end
