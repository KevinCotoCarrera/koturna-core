# Future Robotics Roadmap

## Current State

The fleet layer (`lib/koturna/fleet/`) contains:
- Behaviour contracts for robot ingestion
- Simulation module with fake payload examples
- Architecture documentation

It is NOT integrated into the supervision tree, router, database, or UI.

## Architecture

### Robot Ingestion Pipeline (Planned)

```
Robot -> Edge Gateway -> Koturna Ingestion API -> Oban Jobs -> Inspection Creation
                                                              -> Maintenance Ticket
                                                              -> Building Metric Update
```

### Contract: RobotIngestion

Behaviour defined in `Koturna.Fleet.Contracts.RobotIngestion`:
- `ingest_telemetry/1` — Receive sensor readings
- `ingest_event/1` — Receive discrete events (anomaly detected, checkpoint completed)
- `ingest_spatial_map/1` — Receive lidar/3D maps of inspected spaces

### Robot Types (Planned)

| Type | Purpose | Payload |
|---|---|---|
| **Inspection Drone** | Visual inspection of building exterior/roof | Thermal imagery, HD photos |
| **Indoor Rover** | Interior unit inspection | Lidar maps, air quality, photos |
| **Sensor Node** | Persistent monitoring | Temperature, humidity, vibration |

## Integration Milestones

### Phase 1: Ingestion API (Q4 2024)
- REST endpoint for robot telemetry
- Oban job pipeline for event processing
- Storage for spatial maps in S3

### Phase 2: Inspection Automation (Q1 2025)
- Robot-initiated inspection sessions
- Automated checkpoint completion from sensor data
- Anomaly detection pipeline

### Phase 3: Autonomous Operations (Q3 2025)
- Scheduled autonomous patrols
- Predictive maintenance from sensor trends
- Full digital twin synchronization

## Simulation Module

`Koturna.Fleet.Simulation` provides mock payloads for testing:

```elixir
# Example telemetry payload
%{
  robot_id: "rbt-001",
  timestamp: "2024-01-01T00:00:00Z",
  telemetry: %{
    temperature_c: 23.5,
    humidity_pct: 45.0,
    battery_pct: 87.0,
    location: %{lat: 40.7128, lng: -74.0060}
  }
}
```

## Dependencies (Future)

When activated, the fleet layer will require:
- AWS IoT Core for device communication
- AWS Kinesis for event streaming
- Custom robot firmware (out of scope)

None of these are included in the current codebase.
