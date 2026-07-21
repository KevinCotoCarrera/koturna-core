defmodule Koturna.Fleet.Simulation do
  @moduledoc """
  Simulation module providing fake payload examples for the future fleet layer.

  This module generates realistic-looking telemetry, event, and spatial map
  payloads that can be used for testing the ingestion pipeline once robots
  are integrated. Currently, these are reference examples only — no ingestion
  endpoint processes them.

  ## Usage (future)

      payload = Koturna.Fleet.Simulation.telemetry_payload("rbt-001")
      Koturna.Fleet.Contracts.RobotIngestion.ingest_telemetry(payload)
  """

  @doc """
  Generates a fake telemetry payload for a given robot ID.
  """
  def telemetry_payload(robot_id \\ "rbt-sim-001") do
    %{
      robot_id: robot_id,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      firmware_version: "v2.4.1",
      telemetry: %{
        temperature_c: round_random(18.0, 28.0, 1),
        humidity_pct: round_random(30.0, 70.0, 1),
        air_quality_index: round(Float.round(Enum.random(0..200) + :rand.uniform() * 50, 1)),
        battery_pct: Float.round(100.0 - :rand.uniform() * 30.0, 1),
        location: %{
          lat: 40.7128 + (:rand.uniform() - 0.5) * 0.001,
          lng: -74.0060 + (:rand.uniform() - 0.5) * 0.001,
          floor_number: Enum.random(1..5)
        },
        sensor_status: %{
          lidar: "nominal",
          thermal_camera: "nominal",
          ultrasonic: "nominal",
          imu: "nominal"
        }
      }
    }
  end

  @doc """
  Generates a fake event payload.
  """
  def event_payload(robot_id \\ "rbt-sim-001") do
    event_types = [
      "anomaly_detected",
      "checkpoint_passed",
      "navigation_complete",
      "inspection_aborted",
      "scan_complete"
    ]

    %{
      robot_id: robot_id,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      event_type: Enum.random(event_types),
      data: %{
        location: "Unit 3B — Kitchen",
        confidence: Float.round(0.75 + :rand.uniform() * 0.25, 2),
        details: "Autonomous scan of countertop and sink area completed"
      }
    }
  end

  @doc """
  Generates a fake spatial map payload (mock S3 key reference).
  """
  def spatial_map_payload(robot_id \\ "rbt-sim-001") do
    %{
      robot_id: robot_id,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      map_type: Enum.random(["lidar_point_cloud", "3d_mesh", "floor_plan", "thermal_overlay"]),
      format: Enum.random(["pcd", "ply", "obj", "glb"]),
      resolution_cm: 1.0,
      bounds: %{
        min: %{x: -5.0, y: -3.0, z: 0.0},
        max: %{x: 5.0, y: 3.0, z: 2.5}
      },
      storage_key:
        "fleet/spatial_maps/#{robot_id}/#{DateTime.utc_now() |> DateTime.to_unix()}.ply",
      checksum: "sha256:#{:crypto.strong_rand_bytes(32) |> Base.encode16(case: :lower)}"
    }
  end

  defp round_random(min, max, decimals) do
    value = min + :rand.uniform() * (max - min)
    Float.round(value, decimals)
  end
end
