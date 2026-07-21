defmodule KoturnaWeb.API.UnitController do
  use KoturnaWeb, :controller

  alias Koturna.Properties

  action_fallback KoturnaWeb.API.FallbackController

  def index(conn, %{"building_id" => building_id}) do
    units = Properties.list_units(building_id)
    render(conn, :index, units: units)
  end

  def show(conn, %{"id" => id}) do
    unit = Properties.get_unit!(id)
    render(conn, :show, unit: unit)
  end

  def create(conn, %{"unit" => unit_params}) do
    with {:ok, unit} <- Properties.create_unit(unit_params) do
      conn
      |> put_status(:created)
      |> render(:show, unit: unit)
    end
  end

  def update(conn, %{"id" => id, "unit" => unit_params}) do
    unit = Properties.get_unit!(id)

    with {:ok, unit} <- Properties.update_unit(unit, unit_params) do
      render(conn, :show, unit: unit)
    end
  end
end
