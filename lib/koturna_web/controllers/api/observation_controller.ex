defmodule KoturnaWeb.API.ObservationController do
  use KoturnaWeb, :controller

  alias Koturna.Inspections.InspectionService

  action_fallback KoturnaWeb.API.FallbackController

  def index(conn, %{"inspection_session_id" => session_id}) do
    observations = InspectionService.list_observations(session_id)
    render(conn, :index, observations: observations)
  end

  def show(conn, %{"id" => id}) do
    observation = InspectionService.get_observation!(id)
    render(conn, :show, observation: observation)
  end

  def render(:index, assigns) do
    %{data: for(o <- assigns.observations, do: data(o))}
  end

  def render(:show, assigns) do
    %{data: data(assigns.observation)}
  end

  defp data(observation) do
    %{
      id: observation.id,
      observation_type: observation.observation_type,
      severity: observation.severity,
      confidence: observation.confidence,
      location_label: observation.location_label,
      summary: observation.summary,
      metadata: observation.metadata,
      inspection_session_id: observation.inspection_session_id,
      checkpoint_id: observation.checkpoint_id
    }
  end
end
