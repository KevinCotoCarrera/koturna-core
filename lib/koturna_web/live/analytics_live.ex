defmodule KoturnaWeb.AnalyticsLive do
  use KoturnaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Analytics")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl">
      <h1 class="text-2xl font-bold text-neutral-900">Analytics</h1>
      <p class="mt-1 text-sm text-neutral-500">Building metrics and trend data</p>

      <div class="mt-8">
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="analytics-empty" title="Analytics coming soon" description="Time-series charts, health score trends, and risk distribution will appear here." />
      </div>
    </div>
    """
  end
end
