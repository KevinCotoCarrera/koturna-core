defmodule KoturnaWeb.Components.DesignSystem.HealthScore do
  use Phoenix.LiveComponent

  attr :score, :float, required: true
  attr :size, :string, default: "md"
  attr :show_label, :boolean, default: true

  def render(assigns) do
    assigns = assign(assigns, :grade, grade_for_score(assigns.score))

    ~H"""
    <div class="inline-flex items-center gap-3">
      <div class={["grade-badge", grade_class(@grade), @size == "lg" && "lg"]}>
        <%= @grade %>
      </div>
      <div :if={@show_label}>
        <div class="text-2xl font-bold text-neutral-900"><%= @score %></div>
        <div class="text-xs text-neutral-400">out of 100</div>
      </div>
    </div>
    """
  end

  defp grade_for_score(s) when s >= 90, do: "A"
  defp grade_for_score(s) when s >= 75, do: "B"
  defp grade_for_score(s) when s >= 60, do: "C"
  defp grade_for_score(s) when s >= 40, do: "D"
  defp grade_for_score(_), do: "F"

  defp grade_class("A"), do: "grade-a"
  defp grade_class("B"), do: "grade-b"
  defp grade_class("C"), do: "grade-c"
  defp grade_class("D"), do: "grade-d"
  defp grade_class("F"), do: "grade-f"
end
