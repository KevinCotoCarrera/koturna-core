defmodule Koturna.Privacy.Contracts.DataClassification do
  @moduledoc """
  Defines abstract structs for the privacy classification system.

  These structs represent the taxonomy of data classes in the Selective
  Persistence Architecture. They are used for documentation and type
  specification — no actual instances flow through the system currently.

  ## Data Classes

    * `RawFrame` — Ephemeral, unprocessed robot camera frame (< 5 min TTL)
    * `RedactedFrame` — Frame with person data removed (30 day audit retention)
    * `BuildingEvent` — Structural observation (permanent retention)
    * `InspectionResult` — Human inspector's findings (permanent retention)
    * `TelemetryReading` — Sensor readings, always retained
    * `RetentionDecision` — Metadata about a retention/discard decision
  """

  defmodule RawFrame do
    @moduledoc "Ephemeral raw camera/visual frame. Never persisted."

    defstruct [
      :frame_id,
      :robot_id,
      :timestamp,
      :resolution,
      :contains_humans,
      :ttl_seconds
    ]

    @type t :: %__MODULE__{
            frame_id: binary(),
            robot_id: binary(),
            timestamp: DateTime.t(),
            resolution: binary(),
            contains_humans: boolean(),
            ttl_seconds: integer()
          }
  end

  defmodule RedactedFrame do
    @moduledoc "Frame with person-identifiable data removed. 30-day audit retention."

    defstruct [
      :frame_id,
      :original_frame_id,
      :redaction_method,
      :retained_until,
      :storage_key
    ]

    @type t :: %__MODULE__{
            frame_id: binary(),
            original_frame_id: binary(),
            redaction_method: binary(),
            retained_until: DateTime.t(),
            storage_key: binary()
          }
  end

  defmodule BuildingEvent do
    @moduledoc "Structural/equipment health observation. Permanent retention."

    defstruct [
      :event_id,
      :robot_id,
      :timestamp,
      :event_type,
      :severity,
      :location,
      :metadata
    ]

    @type t :: %__MODULE__{
            event_id: binary(),
            robot_id: binary(),
            timestamp: DateTime.t(),
            event_type: binary(),
            severity: binary(),
            location: binary(),
            metadata: map()
          }
  end

  defmodule RetentionDecision do
    @moduledoc "Metadata about a retention decision."

    defstruct [
      :decision_id,
      :event_id,
      :decision,
      :reason,
      :policy_version,
      :decided_at
    ]

    @type t :: %__MODULE__{
            decision_id: binary(),
            event_id: binary(),
            decision: :retain | :discard | :redact,
            reason: binary(),
            policy_version: binary(),
            decided_at: DateTime.t()
          }
  end
end
