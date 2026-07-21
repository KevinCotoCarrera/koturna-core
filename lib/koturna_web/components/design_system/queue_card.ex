defmodule KoturnaWeb.Components.DesignSystem.QueueCard do
  use Phoenix.LiveComponent

  attr :building, :string, required: true
  attr :unit, :string, required: true
  attr :summary, :string, required: true
  attr :status, :string, required: true
  attr :time_ago, :string, required: true
  attr :action_label, :string, required: true
  attr :action_url, :string, default: nil
  attr :on_action, :any, default: nil
  attr :severity, :string, default: nil
  attr :class, :string, default: ""

  def render(assigns) do
    ~H"""
    <div class={["queue-card", @class]}>
      <div class="flex items-start justify-between">
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2 mb-1">
            <span class="text-sm font-semibold text-neutral-900"><%= @building %></span>
            <span class="text-neutral-300">&middot;</span>
            <span class="text-sm text-neutral-500"><%= @unit %></span>
          </div>
          <p class="text-sm text-neutral-700 line-clamp-2"><%= @summary %></p>
          <div class="mt-3 flex items-center gap-3">
            <span class="text-xs text-neutral-400"><%= @status %></span>
            <span class="text-xs text-neutral-300">&middot;</span>
            <span class="text-xs text-neutral-400"><%= @time_ago %></span>
            <span :if={@severity}>
              <.live_component module={KoturnaWeb.Components.DesignSystem.RiskPill} id={"risk-#{Ecto.UUID.generate()}"} severity={@severity} />
            </span>
          </div>
        </div>
        <button :if={@on_action} phx-click={@on_action} class="btn-secondary text-xs px-3 py-1.5 whitespace-nowrap ml-4">
          <%= @action_label %>
        </button>
        <a :if={@action_url} href={@action_url} class="btn-secondary text-xs px-3 py-1.5 whitespace-nowrap ml-4">
          <%= @action_label %>
        </a>
      </div>
    </div>
    """
  end
end
