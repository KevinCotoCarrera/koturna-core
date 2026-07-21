defmodule Koturna.Properties do
  import Ecto.Query, warn: false
  alias Koturna.Repo
  alias Koturna.Properties.{Building, Floor, Unit, Asset, InventoryItem}

  def list_buildings(org_id) do
    Repo.all(from b in Building, where: b.organization_id == ^org_id, order_by: b.name)
  end

  def get_building!(id), do: Repo.get!(Building, id)
  def get_building(id), do: Repo.get(Building, id)

  def create_building(attrs \\ %{}) do
    %Building{}
    |> Building.changeset(attrs)
    |> Repo.insert()
  end

  def update_building(%Building{} = building, attrs) do
    building
    |> Building.changeset(attrs)
    |> Repo.update()
  end

  def delete_building(%Building{} = building) do
    Repo.delete(building)
  end

  def list_floors(building_id) do
    Repo.all(from f in Floor, where: f.building_id == ^building_id, order_by: f.number)
  end

  def get_floor!(id), do: Repo.get!(Floor, id)

  def create_floor(attrs \\ %{}) do
    %Floor{}
    |> Floor.changeset(attrs)
    |> Repo.insert()
  end

  def update_floor(%Floor{} = floor, attrs) do
    floor
    |> Floor.changeset(attrs)
    |> Repo.update()
  end

  def delete_floor(%Floor{} = floor) do
    Repo.delete(floor)
  end

  def list_units(building_id) do
    Repo.all(from u in Unit, where: u.building_id == ^building_id, order_by: u.unit_number)
  end

  def get_unit!(id) do
    Repo.get!(Unit, id)
    |> Repo.preload([:building, :floor, :assets, :inventory_items])
  end

  def get_unit(id) do
    Repo.get(Unit, id)
    |> case do
      nil -> nil
      unit -> Repo.preload(unit, [:building, :floor])
    end
  end

  def create_unit(attrs \\ %{}) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  def update_unit(%Unit{} = unit, attrs) do
    unit
    |> Unit.changeset(attrs)
    |> Repo.update()
  end

  def delete_unit(%Unit{} = unit) do
    Repo.delete(unit)
  end

  def list_assets(unit_id) do
    Repo.all(from a in Asset, where: a.unit_id == ^unit_id, order_by: a.name)
  end

  def get_asset!(id), do: Repo.get!(Asset, id)

  def create_asset(attrs \\ %{}) do
    %Asset{}
    |> Asset.changeset(attrs)
    |> Repo.insert()
  end

  def update_asset(%Asset{} = asset, attrs) do
    asset
    |> Asset.changeset(attrs)
    |> Repo.update()
  end

  def delete_asset(%Asset{} = asset) do
    Repo.delete(asset)
  end

  def list_inventory(unit_id) do
    Repo.all(from i in InventoryItem, where: i.unit_id == ^unit_id, order_by: i.name)
  end

  def get_inventory_item!(id), do: Repo.get!(InventoryItem, id)

  def create_inventory_item(attrs \\ %{}) do
    %InventoryItem{}
    |> InventoryItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_inventory_item(%InventoryItem{} = item, attrs) do
    item
    |> InventoryItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_inventory_item(%InventoryItem{} = item) do
    Repo.delete(item)
  end
end
