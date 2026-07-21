defmodule KoturnaWeb.UnitLive.Show do
  use KoturnaWeb, :live_view

  alias Koturna.Properties

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    unit = Properties.get_unit(id)
    assets = if unit, do: Properties.list_assets(unit.id), else: []
    inventory = if unit, do: Properties.list_inventory(unit.id), else: []

    socket =
      assign(socket,
        page_title: "Unit #{if unit, do: unit.unit_number, else: id}",
        unit: unit,
        assets: assets,
        inventory: inventory
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl">
      <div :if={@unit == nil}>
        <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="unit-not-found" title="Unit not found" />
      </div>

      <div :if={@unit}>
        <div class="mb-8">
          <a :if={@unit.building} href={"/buildings/#{@unit.building.id}"} class="text-xs text-neutral-400 hover:text-neutral-600">&larr; <%= @unit.building.name %></a>
          <h1 class="text-2xl font-bold text-neutral-900 mt-1">Unit <%= @unit.unit_number %></h1>
          <div class="flex items-center gap-3 mt-1 text-sm text-neutral-400">
            <span><%= @unit.unit_type %></span>
            <span>&middot;</span>
            <span><%= @unit.bedrooms %> beds · <%= @unit.bathrooms %> baths</span>
            <span>&middot;</span>
            <span><%= @unit.square_meters %> m²</span>
            <span class={["px-2 py-0.5 rounded-full text-xs font-medium", occupancy_color(@unit.occupancy_status)]}>
              <%= @unit.occupancy_status %>
            </span>
          </div>
        </div>

        <div class="mb-8">
          <h2 class="text-base font-semibold text-neutral-900 mb-4">Assets</h2>
          <div :if={@assets != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            <.asset_card :for={asset <- @assets} asset={asset} />
          </div>
          <div :if={@assets == []}>
            <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="no-assets" title="No assets" description="No assets registered for this unit." />
          </div>
        </div>

        <div>
          <h2 class="text-base font-semibold text-neutral-900 mb-4">Inventory</h2>
          <div :if={@inventory != []} class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            <.inventory_card :for={item <- @inventory} item={item} />
          </div>
          <div :if={@inventory == []}>
            <.live_component module={KoturnaWeb.Components.DesignSystem.EmptyState} id="no-inventory" title="No inventory" description="No inventory items tracked for this unit." />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp asset_card(assigns) do
    ~H"""
    <div class="bg-white rounded-xl p-4 shadow-sm border border-neutral-100">
      <h3 class="text-sm font-semibold text-neutral-900"><%= @asset.name %></h3>
      <div class="text-xs text-neutral-400 mt-1 space-y-0.5">
        <p><%= @asset.category %> · <%= @asset.manufacturer || "—" %></p>
        <p :if={@asset.serial_number}>SN: <%= @asset.serial_number %></p>
      </div>
    </div>
    """
  end

  defp inventory_card(assigns) do
    ~H"""
    <div class="bg-white rounded-xl p-4 shadow-sm border border-neutral-100">
      <h3 class="text-sm font-semibold text-neutral-900"><%= @item.name %></h3>
      <div class="text-xs text-neutral-400 mt-1">
        <p>SKU: <%= @item.sku || "—" %> · Qty: <%= @item.expected_quantity %></p>
      </div>
    </div>
    """
  end

  defp occupancy_color("occupied"), do: "bg-emerald-100 text-emerald-700"
  defp occupancy_color("vacant"), do: "bg-neutral-100 text-neutral-500"
  defp occupancy_color(_), do: "bg-amber-100 text-amber-700"
end
