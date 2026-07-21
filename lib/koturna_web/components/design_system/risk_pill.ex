defmodule KoturnaWeb.Components.DesignSystem.RiskPill do
  use Phoenix.LiveComponent

  attr :severity, :string, required: true
  attr :class, :string, default: ""

  def render(assigns) do
    ~H"""
    <span class={["risk-pill", risk_class(@severity), @class]}>
      <%= @severity %>
    </span>
    """
  end

  defp risk_class("critical"), do: "risk-critical"
  defp risk_class("high"), do: "risk-high"
  defp risk_class("medium"), do: "risk-medium"
  defp risk_class("low"), do: "risk-low"
  defp risk_class("info"), do: "risk-low"
  defp risk_class(_), do: "risk-low"
end
