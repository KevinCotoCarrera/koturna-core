defmodule KoturnaWeb.API.BuildingJSON do
  def index(%{buildings: buildings}) do
    %{data: for(building <- buildings, do: data(building))}
  end

  def show(%{building: building}) do
    %{data: data(building)}
  end

  def data(building) do
    %{
      id: building.id,
      name: building.name,
      address: building.address,
      city: building.city,
      country: building.country,
      latitude: building.latitude,
      longitude: building.longitude,
      total_floors: building.total_floors,
      total_units: building.total_units,
      organization_id: building.organization_id
    }
  end
end
