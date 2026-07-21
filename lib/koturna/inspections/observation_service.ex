defmodule Koturna.Inspections.ObservationService do
  alias Koturna.Inspections.Observation

  @doc """
  Classifies severity based on observation type and metadata.
  Defaults to the provided severity, but can override based on rules.
  """
  def classify_severity(%Observation{} = observation) do
    observation
  end

  @doc """
  Returns the severity level as an integer for comparison.
  """
  def severity_level(severity) when is_binary(severity) do
    case severity do
      "info" -> 0
      "low" -> 1
      "medium" -> 2
      "high" -> 3
      "critical" -> 4
      _ -> 0
    end
  end

  @doc """
  Generates a human-readable retention reason for a media reference.
  """
  def generate_retention_reason(%Observation{observation_type: type, severity: severity}) do
    case {type, severity} do
      {"damage", sev} when sev in ~w(high critical) ->
        "Insurance claim documentation — retain 5 years"

      {"leak_risk", _} ->
        "Structural integrity assessment — retain per building lifecycle"

      {"safety", sev} when sev in ~w(high critical) ->
        "Safety compliance — retain per regulatory requirement"

      _ ->
        "Routine inspection documentation — retain 1 year"
    end
  end

  @doc """
  Determines whether this observation should generate a maintenance ticket.
  """
  def should_create_ticket?(%Observation{severity: severity, observation_type: type}) do
    cond do
      severity in ~w(high critical) -> true
      severity == "medium" and type in ~w(leak_risk damage safety) -> true
      true -> false
    end
  end
end
