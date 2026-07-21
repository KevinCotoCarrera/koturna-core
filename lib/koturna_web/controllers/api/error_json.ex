defmodule KoturnaWeb.API.ErrorJSON do
  def render("404.json", _assigns) do
    %{error: %{code: 404, message: "Not found"}}
  end

  def render("422.json", %{changeset: changeset}) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    %{error: %{code: 422, message: "Validation failed", details: errors}}
  end
end
