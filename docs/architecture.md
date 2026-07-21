# Koturna Architecture

## Overview

Koturna is a Phoenix-based vertical SaaS platform following Domain-Driven Design (DDD) principles. The system is organized into bounded contexts, each owning its own data, logic, and interface contracts.

## Bounded Contexts

### Identity
Manages users, organizations, and role-based access. Handles authentication via phx.gen.auth with Argon2 hashing.

### Properties
The physical building data layer: buildings, floors, units, assets (AC, appliances, furniture, etc.), and inventory tracking. This is the foundation for all inspection and maintenance workflows.

### Inspections
Orchestrates inspection sessions against units. Sessions contain checkpoints (predefined inspection steps), which produce observations (found conditions). Media references are stored separately in S3.

### Maintenance
Tickets generated from critical observations. Vendor assignment, cost tracking, and lifecycle management. Oban jobs handle automated ticket creation from observation thresholds.

### Analytics
Time-series building metrics and computed health scores. Oban cron jobs run daily aggregations and health score computations. Stores results in `building_metrics` table.

### Fleet (Future)
Placeholder layer for autonomous robot ingestion. Contains behaviour contracts (`koturna/fleet/contracts/robot_ingestion.ex`) but is NOT integrated into the supervision tree, router, or database.

### Privacy (Future)
Placeholder for Selective Persistence Architecture where raw footage is ephemeral and only building-health events are retained. Contains abstract structs and policy documentation but NO video processing implementation.

## Technology Decisions

| Concern | Choice | Rationale |
|---|---|---|
| Web framework | Phoenix LiveView | Server-rendered real-time UI without SPA complexity |
| Background jobs | Oban | Reliable, PostgreSQL-backed job processing |
| API spec | OpenApiSpex | Automatic OpenAPI doc generation from code |
| File storage | ExAws + S3 | Direct S3 abstraction, no local file handling |
| Auth | phx.gen.auth + Argon2 | Stable, Phoenix-native authentication |
| Observability | Telemetry + OpenTelemetry + PromEx | Production-grade metrics and tracing |

## Data Flow

```
Inspection Session -> Checkpoints -> Observations -> (critical? -> Maintenance Ticket)
                                                              |
                                                         Analytics (health score)
```

## Event Bus

Domain events are published via Phoenix PubSub under topic `koturna:events`. See [Event Catalog](event-catalog.md) for full event documentation.

## Deployment

- Docker multi-stage build
- PostgreSQL 16
- Oban for background processing
- S3 for media storage
- CI via GitHub Actions
