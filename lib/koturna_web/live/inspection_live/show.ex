defmodule KoturnaWeb.InspectionLive.Show do
  use KoturnaWeb, :live_view

  alias Koturna.Inspections.InspectionService

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    session = InspectionService.get_session(id)
    checkpoints = if session, do: InspectionService.list_checkpoints(session.id), else: []
    observations = if session, do: InspectionService.list_observations(session.id), else: []

    current_idx = find_current(checkpoints)
    total = length(checkpoints)
    completed = Enum.count(checkpoints, &(not is_nil(&1.completed_at)))

    socket =
      assign(socket,
        page_title: "Inspection",
        session: session,
        checkpoints: checkpoints,
        observations: observations,
        current_idx: current_idx,
        total: total,
        completed: completed,
        drawer_open: false,
        drawer_type: nil,
        form_observation: %{
          observation_type: nil,
          severity: "info",
          confidence: nil,
          location_label: nil,
          summary: nil
        },
        grade: compute_grade(observations)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("next_checkpoint", _, socket) do
    next = min(socket.assigns.current_idx + 1, max(0, socket.assigns.total - 1))
    {:noreply, assign(socket, :current_idx, next)}
  end

  def handle_event("prev_checkpoint", _, socket) do
    prev = max(socket.assigns.current_idx - 1, 0)
    {:noreply, assign(socket, :current_idx, prev)}
  end

  def handle_event("mark_ok", %{"checkpoint_id" => cp_id}, socket) do
    checkpoint = Enum.find(socket.assigns.checkpoints, &(&1.id == cp_id))
    {:ok, _} = InspectionService.complete_checkpoint(checkpoint)
    {:noreply, reload(socket)}
  end

  def handle_event("skip_checkpoint", %{"checkpoint_id" => cp_id}, socket) do
    checkpoint = Enum.find(socket.assigns.checkpoints, &(&1.id == cp_id))
    {:ok, _} = InspectionService.complete_checkpoint(checkpoint)
    {:noreply, reload(socket)}
  end

  def handle_event("open_drawer", %{"type" => type, "checkpoint_id" => cp_id}, socket) do
    {:noreply, assign(socket, drawer_open: true, drawer_type: type, drawer_checkpoint: cp_id)}
  end

  def handle_event("close_drawer", _, socket) do
    {:noreply,
     assign(socket,
       drawer_open: false,
       drawer_type: nil,
       form_observation: %{
         observation_type: nil,
         severity: "info",
         confidence: nil,
         location_label: nil,
         summary: nil
       }
     )}
  end

  def handle_event("save_observation", params, socket) do
    attrs = %{
      inspection_session_id: socket.assigns.session.id,
      checkpoint_id: socket.assigns.drawer_checkpoint,
      observation_type: params["observation_type"],
      severity: params["severity"],
      confidence: parse_float(params["confidence"]),
      location_label: params["location_label"],
      summary: params["summary"]
    }

    case InspectionService.add_observation(attrs) do
      {:ok, _obs} ->
        {:noreply,
         socket
         |> assign(drawer_open: false, drawer_type: nil)
         |> reload()}

      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Invalid: #{inspect(changeset.errors)}")}
    end
  end

  def handle_event("start_session", _, socket) do
    inspector = Koturna.Identity.list_users() |> List.first()

    case InspectionService.start_session(socket.assigns.session, inspector && inspector.id) do
      {:ok, session} -> {:noreply, assign(socket, :session, session)}
      {:error, _} -> {:noreply, socket}
    end
  end

  def handle_event("finalize_session", _, socket) do
    case InspectionService.finalize_session(socket.assigns.session) do
      {:ok, session} ->
        {:noreply,
         socket
         |> assign(:session, session)
         |> put_flash(:info, "Inspection completed")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Cannot finalize: #{reason}")}
    end
  end

  defp reload(socket) do
    session = InspectionService.get_session(socket.assigns.session.id)
    checkpoints = InspectionService.list_checkpoints(session.id)
    observations = InspectionService.list_observations(session.id)
    completed = Enum.count(checkpoints, &(not is_nil(&1.completed_at)))

    current_idx =
      if socket.assigns.current_idx < length(checkpoints), do: socket.assigns.current_idx, else: 0

    assign(socket,
      session: session,
      checkpoints: checkpoints,
      observations: observations,
      completed: completed,
      current_idx: current_idx,
      total: length(checkpoints),
      grade: compute_grade(observations)
    )
  end

  defp find_current(checkpoints) do
    idx = Enum.find_index(checkpoints, &is_nil(&1.completed_at))
    if idx, do: idx, else: length(checkpoints) - 1
  end

  defp parse_float(nil), do: nil
  defp parse_float(""), do: nil
  defp parse_float(s), do: String.to_float(s)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl">
      <div :if={@session == nil}>
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="insp-not-found" title="Session not found" />
      </div>

      <div :if={@session}>
        <div class="flex items-center justify-between mb-6">
          <div>
            <a href="/inspections" class="text-xs text-neutral-400 hover:text-neutral-600">&larr; All Inspections</a>
            <h1 class="text-xl font-bold text-neutral-900 mt-1">
              <%= @session.inspection_type %> — <%= if @session.unit, do: @session.unit.unit_number, else: @session.unit_id %>
            </h1>
            <p :if={@session.building} class="text-sm text-neutral-400 mt-0.5"><%= @session.building.name %></p>
          </div>
          <div class="flex items-center gap-4">
            <.live_component module={KoturnaWeb.Components.DesignSystem.GradeBadge} id="grade-badge" grade={@grade.letter} score={@grade.score} />
            <.live_component module={KoturnaWeb.Components.DesignSystem.WorkflowStepper} id="progress" current_step={@completed} total_steps={@total} />
            <button :if={@session.status == "pending"} phx-click="start_session" class="btn-primary">Start</button>
            <button :if={@session.status == "in_progress"} phx-click="finalize_session" class="btn-primary">Complete</button>
          </div>
        </div>

        <div :if={@session.status != "pending" and @checkpoints != []} class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div class="lg:col-span-1">
            <div class="insight-panel sticky top-8">
              <h3 class="text-sm font-semibold text-neutral-700 mb-3">Checkpoints</h3>
              <div class="space-y-1">
                <div
                  :for={cp <- @checkpoints}
                  class={["stepper-step cursor-pointer", if(cp.completed_at, do: "completed", else: if(index_of(cp, @checkpoints) == @current_idx, do: "current", else: ""))]}
                  phx-click="show_checkpoint"
                  phx-value-id={cp.id}>
                  <div class={["w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold",
                    if(cp.completed_at, do: "bg-emerald-100 text-emerald-700", else: "bg-neutral-100 text-neutral-400")]}>
                    <%= if cp.completed_at, do: "✓", else: index_of(cp, @checkpoints) + 1 %>
                  </div>
                  <div>
                    <p class="text-sm"><%= cp.code %></p>
                    <p class="text-xs text-neutral-400"><%= cp.label %></p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="lg:col-span-2">
            <%= if Enum.at(@checkpoints, @current_idx) do %>
              <% cp = Enum.at(@checkpoints, @current_idx) %>
              <div class="insight-panel">
                <div class="flex items-center justify-between mb-6">
                  <div>
                    <span class="text-xs font-semibold text-neutral-400 uppercase tracking-wider"><%= cp.code %></span>
                    <h2 class="text-lg font-semibold text-neutral-900 mt-0.5"><%= cp.label %></h2>
                    <span :if={cp.required} class="text-xs text-amber-600 font-medium mt-1">Required</span>
                  </div>
                  <.live_component module={KoturnaWeb.Components.DesignSystem.RiskPill} id={"risk-#{cp.id}"} severity={if(cp.completed_at, do: "completed", else: "pending")} />
                </div>

                <div :if={is_nil(cp.completed_at)} class="flex items-center gap-3 mt-6">
                  <button phx-click="mark_ok" phx-value-checkpoint_id={cp.id} class="btn-primary">
                    <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                    Mark OK
                  </button>
                  <button phx-click="open_drawer" phx-value-type="observation" phx-value-checkpoint_id={cp.id} class="btn-secondary">
                    <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v6m3-3H9"/></svg>
                    Capture Observation
                  </button>
                  <button phx-click="skip_checkpoint" phx-value-checkpoint_id={cp.id} class="btn-ghost">Skip</button>
                </div>

                <div :if={not is_nil(cp.completed_at)} class="mt-6">
                  <div class="rounded-xl bg-emerald-50 px-4 py-3 inline-flex items-center gap-2">
                    <svg class="w-4 h-4 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>
                    <span class="text-sm text-emerald-700 font-medium">Completed</span>
                  </div>
                </div>

                <div :if={has_observations?(cp, @observations)} class="mt-6">
                  <h4 class="text-sm font-semibold text-neutral-700 mb-3">Observations</h4>
                  <div :for={obs <- filter_observations(cp, @observations)} class="rounded-xl bg-neutral-50 px-4 py-3 mb-2">
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-neutral-900"><%= obs.observation_type %></span>
                      <.live_component module={KoturnaWeb.Components.DesignSystem.RiskPill} id={"obs-#{obs.id}"} severity={obs.severity} />
                    </div>
                    <p :if={obs.summary} class="text-xs text-neutral-500 mt-1"><%= obs.summary %></p>
                  </div>
                </div>
              </div>
            <% else %>
              <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="no-checkpoints" title="No checkpoints" />
            <% end %>

            <div class="flex items-center justify-between mt-6">
              <button :if={@current_idx > 0} phx-click="prev_checkpoint" class="btn-ghost">&larr; Previous</button>
              <button phx-click="next_checkpoint" class="btn-ghost">Next &rarr;</button>
            </div>
          </div>
        </div>

        <div :if={@session.status == "pending"} class="insight-panel text-center py-12">
          <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="not-started" title="Ready to inspect" description="Press Start to begin the inspection session." />
        </div>
      </div>
    </div>

    <.live_component
      module={KoturnaWeb.Components.DesignSystem.ActionDrawer}
      id="obs-drawer"
      open={@drawer_open}
      title="Capture Observation"
      on_close="close_drawer">
      <form phx-submit="save_observation" class="space-y-5">
        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Type</label>
          <select name="observation_type" class="observation-input">
            <option value="">Select type…</option>
            <option value="damage">Damage</option>
            <option value="leak_risk">Leak Risk</option>
            <option value="ac_condition">AC Condition</option>
            <option value="inventory">Inventory</option>
            <option value="cleaning">Cleaning</option>
            <option value="plant_health">Plant Health</option>
            <option value="safety">Safety</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Severity</label>
          <select name="severity" class="observation-input">
            <option value="info">Info</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="critical">Critical</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Confidence</label>
          <input type="range" name="confidence" min="0" max="1" step="0.1" value="0.9" class="w-full accent-neutral-900" />
        </div>

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Location</label>
          <input type="text" name="location_label" class="observation-input" placeholder="e.g. Kitchen, Bathroom" />
        </div>

        <div>
          <label class="block text-sm font-medium text-neutral-700 mb-1.5">Notes</label>
          <textarea name="summary" rows="3" class="observation-input" placeholder="Describe what you observed…"></textarea>
        </div>

        <div class="flex items-center gap-3 pt-2">
          <button type="submit" class="btn-primary flex-1">Save Observation</button>
          <button type="button" phx-click="close_drawer" class="btn-ghost">Cancel</button>
        </div>
      </form>
    </.live_component>
    """
  end

  defp index_of(item, list) do
    Enum.find_index(list, &(&1.id == item.id))
  end

  defp has_observations?(cp, observations) do
    Enum.any?(observations, &(&1.checkpoint_id == cp.id))
  end

  defp filter_observations(cp, observations) do
    Enum.filter(observations, &(&1.checkpoint_id == cp.id))
  end

  defp compute_grade(observations) do
    deductions =
      Enum.reduce(observations, 0, fn o, acc ->
        case o.severity do
          "critical" -> acc + 28
          "high" -> acc + 15
          "medium" -> acc + 8
          "low" -> acc + 3
          _ -> acc
        end
      end)

    score = max(0, 100 - deductions)

    letter =
      cond do
        score >= 90 -> "A"
        score >= 75 -> "B"
        score >= 60 -> "C"
        score >= 40 -> "D"
        true -> "F"
      end

    %{score: score, letter: letter}
  end
end
