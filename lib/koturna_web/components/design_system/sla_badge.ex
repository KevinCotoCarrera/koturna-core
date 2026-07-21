defmodule KoturnaWeb.Components.DesignSystem.SLABadge do
  use Phoenix.LiveComponent

  attr :status, :string, required: true
  attr :hours_left, :integer, default: nil

  def render(assigns) do
    ~H"""
    <div class={["sla-badge", sla_class(@status)]}>
      <span :if={@status == "ok"} class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
      <span :if={@status == "warning"} class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
      <span :if={@status == "at_risk"} class="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span>
      <span>SLA <%= sla_label(@status) %></span>
    </div>
    """
  end

  defp sla_class("at_risk"), do: "at-risk"
  defp sla_class("warning"), do: "warning"
  defp sla_class("ok"), do: "ok"
  defp sla_class(_), do: "ok"

  defp sla_label("at_risk"), do: "At Risk"
  defp sla_label("warning"), do: "Warning"
  defp sla_label("ok"), do: "OK"
  defp sla_label(_), do: "OK"
end
