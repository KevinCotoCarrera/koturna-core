defmodule KoturnaWeb.API.InspectionController do
  use KoturnaWeb, :controller

  alias Koturna.Inspections.InspectionService

  action_fallback KoturnaWeb.API.FallbackController

  def index(conn, %{"organization_id" => org_id}) do
    sessions = InspectionService.list_sessions(org_id)
    render(conn, :index, sessions: sessions)
  end

  def show(conn, %{"id" => id}) do
    session = InspectionService.get_session!(id)
    render(conn, :show, session: session)
  end

  def create(conn, %{"inspection_session" => params}) do
    with {:ok, session} <- InspectionService.create_session(params) do
      conn
      |> put_status(:created)
      |> render(:show, session: session)
    end
  end

  def start(conn, %{"id" => id, "inspector_user_id" => inspector_user_id}) do
    session = InspectionService.get_session!(id)

    with {:ok, session} <- InspectionService.start_session(session, inspector_user_id) do
      render(conn, :show, session: session)
    end
  end

  def finalize(conn, %{"id" => id}) do
    session = InspectionService.get_session!(id)

    with {:ok, session} <- InspectionService.finalize_session(session) do
      render(conn, :show, session: session)
    end
  end

  def add_observation(conn, %{"id" => id, "observation" => observation_params}) do
    params = Map.put(observation_params, "inspection_session_id", id)

    with {:ok, observation} <- InspectionService.add_observation(params) do
      conn
      |> put_status(:created)
      |> json(%{data: observation_data(observation)})
    end
  end

  defp observation_data(observation) do
    %{
      id: observation.id,
      observation_type: observation.observation_type,
      severity: observation.severity,
      summary: observation.summary,
      location_label: observation.location_label,
      confidence: observation.confidence,
      inspection_session_id: observation.inspection_session_id,
      checkpoint_id: observation.checkpoint_id
    }
  end
end
