defmodule KoturnaWeb.API.FallbackController do
  use Phoenix.Controller, formats: [:json]

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: KoturnaWeb.API.ErrorJSON)
    |> render(:"422", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: KoturnaWeb.API.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, reason}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: reason})
  end
end
