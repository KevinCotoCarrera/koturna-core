defmodule KoturnaWeb.Components.DesignSystem.ActionDrawer do
  use Phoenix.LiveComponent

  attr :open, :boolean, default: false
  attr :title, :string, default: ""
  attr :on_close, :any, default: nil
  slot :inner_block, required: true

  def render(assigns) do
    ~H"""
    <div class={["relative z-50", if(@open, do: "", else: "hidden")]} role="dialog" aria-modal={@open}>
      <div :if={@open} class="drawer-overlay" phx-click={@on_close}></div>
      <div :if={@open} class="drawer-panel">
        <div class="px-6 py-5 border-b border-neutral-100 flex items-center justify-between">
          <h2 class="text-base font-semibold text-neutral-900"><%= @title %></h2>
          <button phx-click={@on_close} class="p-2 -mr-2 rounded-xl hover:bg-neutral-100" aria-label="Close">
            <svg class="w-5 h-5 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </div>
        <div class="px-6 py-5">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
