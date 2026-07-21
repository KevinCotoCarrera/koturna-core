defmodule KoturnaWeb.API.InspectionJSON do
  def index(%{sessions: sessions}) do
    %{data: for(session <- sessions, do: data(session))}
  end

  def show(%{session: session}) do
    %{data: data(session)}
  end

  def data(session) do
    %{
      id: session.id,
      inspection_type: session.inspection_type,
      status: session.status,
      started_at: session.started_at,
      completed_at: session.completed_at,
      route_version: session.route_version,
      organization_id: session.organization_id,
      building_id: session.building_id,
      unit_id: session.unit_id,
      inspector_user_id: session.inspector_user_id
    }
  end
end
