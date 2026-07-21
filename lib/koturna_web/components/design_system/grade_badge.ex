defmodule KoturnaWeb.Components.DesignSystem.GradeBadge do
  use Phoenix.LiveComponent

  attr :grade, :string, required: true
  attr :score, :float, default: nil
  attr :size, :string, default: "md"
  attr :show_trend, :boolean, default: false
  attr :trend, :atom, default: nil
  attr :class, :string, default: ""

  def render(assigns) do
    ~H"""
    <div class="inline-flex items-center gap-2">
      <div class={["grade-badge", grade_class(@grade), @size, @class]}>
        <%= @grade %>
      </div>
      <div :if={@score} class="flex flex-col">
        <span class="text-sm font-semibold text-neutral-800"><%= @score %></span>
          <div :if={@show_trend && @trend} class="flex items-center gap-1 text-xs text-neutral-400">
          <span :if={@trend == :up} class="text-emerald-500">&uarr;</span>
          <span :if={@trend == :down} class="text-red-500">&darr;</span>
          <span :if={@trend == :stable}>&rarr;</span>
        </div>
      </div>
    </div>
    """
  end

  defp grade_class(grade) when grade in ~w(A+ A), do: "grade-a"
  defp grade_class("B"), do: "grade-b"
  defp grade_class("C"), do: "grade-c"
  defp grade_class("D"), do: "grade-d"
  defp grade_class("F"), do: "grade-f"
  defp grade_class(_), do: "grade-c"
end
