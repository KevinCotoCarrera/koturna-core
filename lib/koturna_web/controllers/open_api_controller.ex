defmodule KoturnaWeb.OpenApiController do
  use Phoenix.Controller, formats: [:json]

  alias KoturnaWeb.ApiSpec

  def spec(conn, _params) do
    json(conn, ApiSpec.spec())
  end
end
