defmodule Koturna.Privacy.Examples.PrivacyScenarios do
  @moduledoc """
  Worked examples of privacy decisions in the Selective Persistence Architecture.

  These examples illustrate the intended behavior of the privacy layer when
  robot ingestion is activated. They are documentation, not executable code.

  ## Scenario 1: Crack Detection (RETAIN)

      Robot inspects Unit 3B kitchen.
      Camera detects a crack in the countertop.
      No humans in frame.
      AI classifies as "damage" with severity "medium".
      Result: BuildingEvent retained. RawFrame discarded.

  ## Scenario 2: Leak Detection + Human (REDACT -> RETAIN)

      Robot inspects Unit 5A bathroom.
      Camera detects water leak under sink.
      Short-term guest is visible in bathroom mirror.
      Edge AI redacts the human silhouette.
      Result: RedactedFrame retained for 30 days. BuildingEvent (leak) retained permanently.

  ## Scenario 3: Navigation Only (DISCARD)

      Robot navigates hallway between units.
      No anomalies detected, no structural observations.
      Result: All frames discarded. No data retained.

  ## Scenario 4: Person-Only Frame (DISCARD)

      Robot frames capture a person walking through the lobby.
      No building health data present.
      Result: Frame immediately discarded. Zero retention.
  """

  @doc """
  Returns a list of all documented privacy scenarios.
  """
  def scenarios do
    [
      %{
        id: "scenario-1",
        name: "Crack Detection",
        has_humans: false,
        has_building_event: true,
        decision: :retain,
        building_event_type: "damage"
      },
      %{
        id: "scenario-2",
        name: "Leak Detection + Human",
        has_humans: true,
        has_building_event: true,
        decision: :redact_and_retain,
        building_event_type: "leak_risk"
      },
      %{
        id: "scenario-3",
        name: "Navigation Only",
        has_humans: false,
        has_building_event: false,
        decision: :discard,
        building_event_type: nil
      },
      %{
        id: "scenario-4",
        name: "Person-Only Frame",
        has_humans: true,
        has_building_event: false,
        decision: :discard,
        building_event_type: nil
      }
    ]
  end
end
