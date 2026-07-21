defmodule Koturna.Inspections.InspectionService do
  import Ecto.Query, warn: false
  alias Koturna.Events
  alias Koturna.Inspections.{InspectionCheckpoint, InspectionSession, Observation}
  alias Koturna.Repo

  @doc """
  Creates a new inspection session in 'pending' state.
  """
  def create_session(attrs) do
    %InspectionSession{status: "pending"}
    |> InspectionSession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Starts an inspection session (pending -> in_progress).
  """
  def start_session(%InspectionSession{status: "pending"} = session, inspector_user_id) do
    session
    |> InspectionSession.changeset(%{
      status: "in_progress",
      inspector_user_id: inspector_user_id,
      started_at: DateTime.utc_now()
    })
    |> Repo.update()
    |> case do
      {:ok, started_session} ->
        Events.inspection_started(started_session)
        {:ok, started_session}

      error ->
        error
    end
  end

  def start_session(_session, _inspector_user_id) do
    {:error, :invalid_session_status}
  end

  @doc """
  Marks a checkpoint as completed.
  """
  def complete_checkpoint(%InspectionCheckpoint{} = checkpoint, completed_at \\ nil) do
    ts = completed_at || DateTime.utc_now()

    checkpoint
    |> InspectionCheckpoint.changeset(%{completed_at: ts})
    |> Repo.update()
  end

  @doc """
  Adds an observation to an inspection session, optionally linked to a checkpoint.
  """
  def add_observation(attrs) do
    %Observation{}
    |> Observation.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, observation} ->
        if Observation.critical?(observation) do
          Events.observation_critical(observation)
        end

        Events.observation_created(observation)
        {:ok, observation}

      error ->
        error
    end
  end

  @doc """
  Finalizes an inspection session (in_progress -> completed).
  Validates all required checkpoints are done.
  """
  def finalize_session(%InspectionSession{status: "in_progress"} = session) do
    checkpoints = list_checkpoints(session.id)
    pending_required = Enum.any?(checkpoints, fn cp -> cp.required && is_nil(cp.completed_at) end)

    if pending_required do
      {:error, :pending_required_checkpoints}
    else
      session
      |> InspectionSession.changeset(%{
        status: "completed",
        completed_at: DateTime.utc_now()
      })
      |> Repo.update()
      |> case do
        {:ok, completed_session} ->
          Events.inspection_completed(completed_session)
          {:ok, completed_session}

        error ->
          error
      end
    end
  end

  def finalize_session(_session) do
    {:error, :invalid_session_status}
  end

  def list_sessions(org_id) do
    Repo.all(
      from s in InspectionSession,
        where: s.organization_id == ^org_id,
        order_by: [desc: s.inserted_at],
        preload: [:unit, :building, :inspector]
    )
  end

  def get_session!(id) do
    Repo.preload(Repo.get!(InspectionSession, id), [
      :unit,
      :building,
      :inspector,
      :checkpoints,
      :observations
    ])
  end

  def get_session(id) do
    case Repo.get(InspectionSession, id) do
      nil -> nil
      session -> Repo.preload(session, [:unit, :building, :inspector, :checkpoints])
    end
  end

  def list_checkpoints(session_id) do
    Repo.all(
      from c in InspectionCheckpoint,
        where: c.inspection_session_id == ^session_id,
        order_by: c.code
    )
  end

  def create_checkpoint(attrs \\ %{}) do
    %InspectionCheckpoint{}
    |> InspectionCheckpoint.changeset(attrs)
    |> Repo.insert()
  end

  def list_observations(session_id) do
    Repo.all(
      from o in Observation,
        where: o.inspection_session_id == ^session_id,
        order_by: [desc: o.severity],
        preload: [:checkpoint, :media_references]
    )
  end

  def get_observation!(id) do
    Repo.preload(Repo.get!(Observation, id), [:inspection_session, :checkpoint, :media_references])
  end
end
