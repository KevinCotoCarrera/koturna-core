# Koturna Event Catalog

All domain events are published via `Phoenix.PubSub` under topic `"koturna:events"`.

## Event Format

```json
{
  "event": "domain.event_name",
  "payload": {},
  "metadata": {
    "timestamp": "2024-01-01T00:00:00Z",
    "source": "module_name"
  }
}
```

## Events

### inspection.started
Emitted when an inspection session transitions from `pending` to `in_progress`.

Payload:
```json
{
  "inspection_session_id": "uuid",
  "organization_id": "uuid",
  "building_id": "uuid",
  "unit_id": "uuid",
  "inspector_user_id": "uuid",
  "inspection_type": "checkout"
}
```

### inspection.completed
Emitted when all required checkpoints are completed.

Payload:
```json
{
  "inspection_session_id": "uuid",
  "organization_id": "uuid",
  "unit_id": "uuid",
  "completed_at": "2024-01-01T00:00:00Z",
  "total_observations": 5,
  "critical_observations": 1
}
```

### observation.created
Emitted when a new observation is recorded.

Payload:
```json
{
  "observation_id": "uuid",
  "inspection_session_id": "uuid",
  "observation_type": "leak_risk",
  "severity": "critical",
  "unit_id": "uuid"
}
```

### observation.critical
Emitted when an observation with `severity == "critical"` is created. Triggers automatic ticket creation.

Payload:
```json
{
  "observation_id": "uuid",
  "inspection_session_id": "uuid",
  "observation_type": "leak_risk",
  "unit_id": "uuid",
  "building_id": "uuid",
  "summary": "Active leak detected under kitchen sink"
}
```

### ticket.created
Emitted when a maintenance ticket is created.

Payload:
```json
{
  "ticket_id": "uuid",
  "organization_id": "uuid",
  "building_id": "uuid",
  "unit_id": "uuid",
  "priority": "high",
  "source_observation_id": "uuid"
}
```

### ticket.closed
Emitted when a ticket transitions to `closed` or `resolved`.

Payload:
```json
{
  "ticket_id": "uuid",
  "organization_id": "uuid",
  "actual_cost_cents": 15000,
  "resolved_at": "2024-01-05T00:00:00Z"
}
```

## Subscribing

```elixir
Phoenix.PubSub.subscribe(Koturna.PubSub, "koturna:events")
```

## Future Events (Robotics)

When the fleet layer is activated:
- `robot.telemetry_received`
- `robot.spatial_map_ingested`
- `robot.anomaly_detected`
