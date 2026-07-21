defmodule KoturnaWeb.SettingsLive do
  use KoturnaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Settings")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl">
      <h1 class="text-2xl font-bold text-neutral-900">Settings</h1>
      <p class="mt-1 text-sm text-neutral-500">Organization configuration</p>

      <div class="mt-8">
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="settings-empty" title="Settings coming soon" description="User management, notification preferences, and integration configuration will appear here." />
      </div>
    </div>
    """
  end
end
