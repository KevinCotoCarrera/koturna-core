defmodule KoturnaWeb.API.BuildingController do
  use KoturnaWeb, :controller

  alias Koturna.Properties

  action_fallback KoturnaWeb.API.FallbackController

  def index(conn, %{"organization_id" => org_id}) do
    buildings = Properties.list_buildings(org_id)
    render(conn, :index, buildings: buildings)
  end

  def show(conn, %{"id" => id}) do
    building = Properties.get_building!(id)
    render(conn, :show, building: building)
  end

  def create(conn, %{"building" => building_params}) do
    with {:ok, building} <- Properties.create_building(building_params) do
      conn
      |> put_status(:created)
      |> render(:show, building: building)
    end
  end

  def update(conn, %{"id" => id, "building" => building_params}) do
    building = Properties.get_building!(id)

    with {:ok, building} <- Properties.update_building(building, building_params) do
      render(conn, :show, building: building)
    end
  end
end
