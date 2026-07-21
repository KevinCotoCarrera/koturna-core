defmodule Koturna.Fleet.Contracts.RobotIngestion do
  @moduledoc """
  Behaviour contract for autonomous robot ingestion.

  This module defines the interface that all robot adapters must implement.
  It is intentionally decoupled from the current database, API, and supervision tree.
  No robots are currently integrated — this is a forward-looking architecture placeholder.

  ## Callbacks

    * `ingest_telemetry/1` — Receive sensor telemetry from a robot
    * `ingest_event/1` — Receive discrete events (anomaly detected, inspection step completed)
    * `ingest_spatial_map/1` — Receive lidar/3D spatial maps of inspected spaces
  """

  @doc """
  Ingests raw telemetry data from a robot.

  The payload is expected to contain sensor readings such as temperature,
  humidity, air quality, and battery level. This data does NOT flow into
  the main database — it stays within the fleet layer's ephemeral storage
  and is discarded after processing.
  """
  @callback ingest_telemetry(payload :: map()) :: {:ok, term()} | {:error, term()}

  @doc """
  Ingests a discrete event from a robot.

  Events include: anomaly_detected, checkpoint_passed, navigation_complete,
  inspection_aborted. These may trigger downstream actions via PubSub
  but are NOT persisted in the core database.
  """
  @callback ingest_event(payload :: map()) :: {:ok, term()} | {:error, term()}

  @doc """
  Ingests a spatial map (lidar point cloud, 3D mesh, floor plan).

  Spatial data is stored in object storage (S3), not in PostgreSQL.
  A reference is kept but the raw data is treated as opaque.
  """
  @callback ingest_spatial_map(payload :: map()) :: {:ok, term()} | {:error, term()}
end
