defmodule KoturnaWeb.Router do
  use KoturnaWeb, :router

  import Phoenix.LiveView.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/api" do
    pipe_through :api

    scope "/v1", KoturnaWeb.API, as: :api_v1 do
      resources "/buildings", BuildingController, only: [:index, :show, :create, :update]
      resources "/units", UnitController, only: [:index, :show, :create, :update]
      resources "/inspections", InspectionController, only: [:index, :show, :create]
      post "/inspections/:id/start", InspectionController, :start
      post "/inspections/:id/finalize", InspectionController, :finalize
      post "/inspections/:id/observations", InspectionController, :add_observation
      resources "/observations", ObservationController, only: [:index, :show]
      resources "/tickets", TicketController, only: [:index, :show, :create, :update]
      post "/tickets/:id/assign", TicketController, :assign
      post "/tickets/:id/close", TicketController, :close
      resources "/metrics", MetricController, only: [:index]
    end

    get "/openapi.json", KoturnaWeb.OpenApiController, :spec
  end

  scope "/", KoturnaWeb do
    pipe_through :browser

    live "/", OperationsLive, :index
    live "/buildings", BuildingLive.Index, :index
    live "/buildings/:id", BuildingLive.Show, :show
    live "/units/:id", UnitLive.Show, :show
    live "/inspections", InspectionLive.Index, :index
    live "/inspections/:id", InspectionLive.Show, :show
    live "/maintenance", MaintenanceLive.Index, :index
    live "/analytics", AnalyticsLive, :index
    live "/settings", SettingsLive, :index
  end
end
