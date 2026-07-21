defmodule KoturnaWeb.Components.DesignSystem.WorkflowCard do
  use Phoenix.LiveComponent

  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :status, :string, default: nil
  attr :time_ago, :string, default: nil
  attr :action_label, :string, default: nil
  attr :action_url, :string, default: nil
  attr :on_action, :any, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: false

  def render(assigns) do
    ~H"""
    <div class={["workflow-card", @class]}>
      <div class="flex items-start justify-between gap-4">
        <div class="flex-1 min-w-0">
          <h3 class="text-sm font-semibold text-neutral-900 truncate"><%= @title %></h3>
          <p :if={@subtitle} class="mt-1 text-xs text-neutral-500"><%= @subtitle %></p>
          <div :if={@status || @time_ago} class="mt-2 flex items-center gap-3">
            <span :if={@status} class="text-xs text-neutral-400"><%= @status %></span>
            <span :if={@time_ago} class="text-xs text-neutral-400">&middot; <%= @time_ago %></span>
          </div>
        </div>
        <button :if={@action_label && @on_action} phx-click={@on_action} class="btn-primary text-xs px-3 py-1.5">
          <%= @action_label %>
        </button>
        <a :if={@action_label && @action_url} href={@action_url} class="btn-primary text-xs px-3 py-1.5">
          <%= @action_label %>
        </a>
      </div>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
