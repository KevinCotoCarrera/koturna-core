defmodule KoturnaWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Server}

  alias KoturnaWeb.API.{
    BuildingController,
    InspectionController,
    MetricController,
    TicketController,
    UnitController
  }

  def spec do
    spec = %OpenApi{
      info: %Info{
        title: "Koturna API",
        version: "1.0.0",
        description: "Building data layer and inspection management API"
      },
      servers: [
        %Server{url: "http://localhost:4000", description: "Local"},
        %Server{url: "https://api.koturna.io", description: "Production"}
      ],
      paths: %{
        "/api/v1/buildings" => operations(BuildingController, :index),
        "/api/v1/buildings/{id}" => operations(BuildingController, :show),
        "/api/v1/units" => operations(UnitController, :index),
        "/api/v1/units/{id}" => operations(UnitController, :show),
        "/api/v1/inspections" => operations(InspectionController, :index),
        "/api/v1/inspections/{id}" => operations(InspectionController, :show),
        "/api/v1/tickets" => operations(TicketController, :index),
        "/api/v1/tickets/{id}" => operations(TicketController, :show),
        "/api/v1/metrics" => operations(MetricController, :index)
      }
    }

    OpenApiSpex.resolve_schema_modules(spec)
  end

  defp operations(_module, _action) do
    %{}
  end
end
