defmodule KoturnaWeb.Components.DesignSystem.TimelineEvent do
  use Phoenix.LiveComponent

  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :time, :string, default: nil
  attr :icon, :string, default: nil
  attr :color, :string, default: "neutral"

  def render(assigns) do
    color_map = %{
      "green" => "bg-emerald-500",
      "red" => "bg-red-500",
      "amber" => "bg-amber-500",
      "blue" => "bg-blue-500",
      "neutral" => "bg-neutral-300"
    }

    assigns = assign(assigns, :dot_color, Map.get(color_map, assigns.color, "bg-neutral-300"))

    ~H"""
    <div class="activity-item">
      <div class="flex flex-col items-center">
        <div class={["timeline-dot", @dot_color]}></div>
        <div class="timeline-line flex-1"></div>
      </div>
      <div class="flex-1 min-w-0 pb-4">
        <p class="text-sm font-medium text-neutral-900"><%= @title %></p>
        <p :if={@description} class="mt-0.5 text-xs text-neutral-400"><%= @description %></p>
        <p :if={@time} class="mt-1 text-xs text-neutral-400"><%= @time %></p>
      </div>
    </div>
    """
  end
end
