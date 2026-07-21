defmodule KoturnaWeb.Components.DesignSystem.EmptyState do
  use Phoenix.LiveComponent

  attr :title, :string, default: "Nothing here yet"
  attr :description, :string, default: ""
  attr :icon, :string, default: "document"

  def render(assigns) do
    ~H"""
    <div class="empty-state">
      <div class="w-16 h-16 rounded-2xl bg-neutral-100 flex items-center justify-center mb-4">
        <svg class="w-8 h-8 text-neutral-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={icon_path(@icon)}/>
        </svg>
      </div>
      <h3 class="text-base font-semibold text-neutral-700"><%= @title %></h3>
      <p :if={@description != ""} class="mt-1 text-sm text-neutral-400"><%= @description %></p>
    </div>
    """
  end

  defp icon_path("document"),
    do:
      "M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"
end
