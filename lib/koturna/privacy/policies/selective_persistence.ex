defmodule Koturna.Privacy.Policies.SelectivePersistence do
  @moduledoc """
  Selective Persistence Architecture

  ## Philosophy

  Koturna is a building-health platform, NOT a surveillance system. This module
  defines the framework for ensuring that:

  1. **Raw footage is ephemeral** — Robot camera/visual data exists only in memory
     at the edge device. It is NEVER persisted to disk or transmitted to the cloud.

  2. **Person-related data is discarded** — Any detected humans in robot imagery
     trigger immediate redaction. No facial recognition, behavioral tracking, or
     biometric data is collected.

  3. **Only building-health events are retained** — The output of autonomous
     inspection is a set of structured observations (cracks, leaks, temperature
     anomalies). These are the ONLY data that enter the long-term database.

  ## Architecture Pipeline (Future)

      RawFrame -> [Edge AI Processing] -> BuildingEvent -> RetentionDecision
                                                    |
                                              RedactedFrame (audit-only, 30 days)

  ## Current Status

  This module is an ARCHITECTURE PLACEHOLDER. It defines the philosophy and
  abstract structures but contains NO video processing code, NO frame storage,
  and NO endpoints. The fleet layer (`Koturna.Fleet`) is also a placeholder.

  When robot ingestion is activated, privacy filtering is MANDATORY at the
  edge layer before any data enters the Koturna system.
  """

  @doc """
  Determines whether a building event should be retained.

  Events are retained if they represent structural or equipment health data
  (cracks, leaks, temperature anomalies, equipment status). Transient data
  (robot position logs, raw sensor streams) is discarded.

  Currently returns `:retain` as a placeholder — in production, this would
  evaluate the event against a rules engine.
  """
  def retention_decision(%{event_type: type})
      when type in ~w(anomaly_detected damage leak_risk temperature_alert) do
    :retain
  end

  def retention_decision(%{event_type: type})
      when type in ~w(robot_position battery_status navigation_log) do
    :discard
  end

  def retention_decision(_event) do
    :discard
  end
end
