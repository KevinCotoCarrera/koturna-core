defmodule KoturnaWeb.Components.DesignSystem.WorkflowStepper do
  use Phoenix.LiveComponent

  attr :current_step, :integer, required: true
  attr :total_steps, :integer, required: true
  attr :label, :string, default: nil

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <div class="flex items-center justify-between mb-2">
        <span class="text-sm font-medium text-neutral-700"><%= @label || "Progress" %></span>
        <span class="text-xs text-neutral-400"><%= @current_step %> / <%= @total_steps %></span>
      </div>
      <div class="progress-bar">
        <div class="progress-fill" style={"width: #{min(100, @current_step / max(1, @total_steps) * 100)}%"}></div>
      </div>
    </div>
    """
  end
end
