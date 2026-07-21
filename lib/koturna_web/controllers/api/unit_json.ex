defmodule KoturnaWeb.API.UnitJSON do
  def index(%{units: units}) do
    %{data: for(unit <- units, do: data(unit))}
  end

  def show(%{unit: unit}) do
    %{data: data(unit)}
  end

  def data(unit) do
    %{
      id: unit.id,
      unit_number: unit.unit_number,
      unit_type: unit.unit_type,
      bedrooms: unit.bedrooms,
      bathrooms: unit.bathrooms,
      square_meters: unit.square_meters,
      occupancy_status: unit.occupancy_status,
      building_id: unit.building_id,
      floor_id: unit.floor_id
    }
  end
end
