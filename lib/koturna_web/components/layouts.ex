defmodule KoturnaWeb.Layouts do
  use KoturnaWeb, :component

  def app(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()} />
        <.live_title><%= assigns[:page_title] || "Koturna" %></.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}>
        </script>
      </head>
      <body class="h-full bg-neutral-50">
        <div class="flex h-full">
          <!-- Sidebar -->
          <aside class="sidebar fixed lg:sticky top-0 left-0 z-40 h-full w-60 bg-white border-r border-neutral-100 flex flex-col lg:translate-x-0">
            <div class="flex items-center gap-2 px-5 h-16 border-b border-neutral-100">
              <div class="w-7 h-7 rounded-lg bg-neutral-900 flex items-center justify-center">
                <span class="text-white text-xs font-bold">K</span>
              </div>
              <span class="text-base font-semibold text-neutral-900">Koturna</span>
            </div>

            <nav class="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
              <.sidebar_link navigate="/" icon="chart-pie" label="Operations" />
              <.sidebar_link navigate="/buildings" icon="building-office" label="Buildings" />
              <.sidebar_link navigate="/inspections" icon="clipboard-document-check" label="Inspections" />
              <.sidebar_link navigate="/maintenance" icon="wrench-screwdriver" label="Maintenance" />
              <.sidebar_link navigate="/analytics" icon="arrow-trending-up" label="Analytics" />
              <.sidebar_link navigate="/settings" icon="cog-6-tooth" label="Settings" />
            </nav>

            <div class="px-3 py-4 border-t border-neutral-100">
              <div class="flex items-center gap-3 px-3 py-2.5 text-sm text-neutral-500">
                <div class="w-8 h-8 rounded-full bg-neutral-200 flex items-center justify-center">
                  <span class="text-xs font-medium text-neutral-500">AC</span>
                </div>
                <span class="font-medium text-neutral-700">Alice Chen</span>
              </div>
            </div>
          </aside>

          <!-- Mobile overlay -->
          <div id="sidebar-overlay" class="fixed inset-0 bg-black/20 z-30 hidden" phx-click={Phoenix.LiveView.JS.remove_class("open", to: "#sidebar") |> Phoenix.LiveView.JS.hide(to: "#sidebar-overlay")}></div>

          <!-- Main content -->
          <div class="flex-1 flex flex-col min-w-0">
            <!-- Top bar (mobile nav trigger + page context) -->
            <header class="lg:hidden flex items-center gap-3 px-4 h-14 bg-white border-b border-neutral-100">
              <button phx-click={Phoenix.LiveView.JS.toggle_class("open", to: "#sidebar") |> Phoenix.LiveView.JS.show(to: "#sidebar-overlay")} class="p-2 -ml-2 rounded-xl hover:bg-neutral-100" aria-label="Open navigation">
                <svg class="w-5 h-5 text-neutral-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
              </button>
              <span class="text-sm font-semibold text-neutral-900"><%= assigns[:page_title] || "Koturna" %></span>
            </header>

            <!-- Flash -->
            <div :if={Phoenix.Flash.get(@flash, :info)} class="px-6 pt-4">
              <div class="rounded-xl bg-emerald-50 px-4 py-3 text-sm text-emerald-700"><%= Phoenix.Flash.get(@flash, :info) %></div>
            </div>
            <div :if={Phoenix.Flash.get(@flash, :error)} class="px-6 pt-4">
              <div class="rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700"><%= Phoenix.Flash.get(@flash, :error) %></div>
            </div>

            <main class="flex-1 px-6 py-6 lg:px-8 lg:py-8 overflow-y-auto">
              <%= @inner_content %>
            </main>
          </div>
        </div>
      </body>
    </html>
    """
  end

  attr :navigate, :string, required: true
  attr :icon, :string, required: true
  attr :label, :string, required: true

  def sidebar_link(assigns) do
    ~H"""
    <a href={@navigate} class="sidebar-link">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d={icon_path(@icon)}/></svg>
      <%= @label %>
    </a>
    """
  end

  defp icon_path("chart-pie"), do: "M3 12a9 9 0 1118 0 9 9 0 01-18 0z M7 12a5 5 0 0110 0"

  defp icon_path("building-office"),
    do:
      "M3 21V7l9-4 9 4v14 M9 21V9l3-1.5M9 21h6m0 0v-6h-3v6 M9 13h.01M13 13h.01M17 13h.01M9 17h.01M13 17h.01M17 17h.01"

  defp icon_path("clipboard-document-check"),
    do:
      "M9 12h6M9 16h6M7 4h10a2 2 0 012 2v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6a2 2 0 012-2zM9 2v4h6V2"

  defp icon_path("wrench-screwdriver"),
    do:
      "M9 3.75H6.912a2.25 2.25 0 00-2.15 1.588L2.35 13.177a2.25 2.25 0 00-.1.661V18a2.25 2.25 0 002.25 2.25h15A2.25 2.25 0 0021.75 18v-4.162c0-.224-.034-.447-.1-.661L19.24 5.338a2.25 2.25 0 00-2.15-1.588H15M2.25 13.5h19.5"

  defp icon_path("arrow-trending-up"),
    do:
      "M2.25 18L9 11.25l4.306 4.307a11.95 11.95 0 015.814-5.519l2.74-1.22m0 0l-5.94-2.28m5.94 2.28l-2.28 5.941"

  defp icon_path("cog-6-tooth"),
    do:
      "M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.241-.438.613-.431.992a7.723 7.723 0 010 .255c-.007.378.138.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 010-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28z M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z"
end
