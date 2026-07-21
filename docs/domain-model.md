# Koturna Domain Model

## Core Entities

### Organization
Top-level tenant boundary. All data is scoped to an organization.

### User
Authenticated user with email/password. Linked to organizations via memberships.

### OrganizationMembership
Associates a user with an organization and assigns a role (owner, manager, inspector, vendor).

### Building
A physical structure belonging to an organization. Has address, geo-coordinates, floor count.

### Floor
A numbered level within a building.

### Unit
An individual rental unit (apartment, studio, penthouse). Has bedrooms, bathrooms, square meters, and occupancy status.

### Asset
A physical item within a unit that requires inspection (AC unit, appliance, furniture, plant, fixture, safety equipment).

### InventoryItem
Expected inventory within a unit, tracked by SKU and quantity.

### InspectionSession
An inspection event for a specific unit, performed by an inspector. Has type (checkout, maintenance, audit, move_in, move_out) and status.

### InspectionCheckpoint
A specific step within an inspection session (e.g., "AC-01: Check filter condition").

### Observation
A finding recorded during inspection. Has type (damage, leak_risk, ac_condition, etc.) and severity (info through critical). High/critical observations may generate maintenance tickets.

### MediaReference
A pointer to a file stored in S3, linked to an observation. Never stores raw files.

### MaintenanceTicket
A work order generated from an observation. Tracks priority, status, estimated/actual costs, and assigned vendor.

### Vendor
A service provider (plumber, electrician, etc.) linked to an organization.

### BuildingMetric
A time-series data point for building analytics (temperature, humidity, health score, risk score, etc.).

## Relationship Diagram

```
Organization 1--* Building 1--* Floor 1--* Unit
Organization 1--* User (via OrganizationMembership)
Unit 1--* Asset
Unit 1--* InventoryItem
Unit 1--* InspectionSession
InspectionSession 1--* InspectionCheckpoint
InspectionSession 1--* Observation
Observation 1--* MediaReference
Observation 0..1--1 MaintenanceTicket
Organization 1--* Vendor
Vendor 0..1--* MaintenanceTicket
Building 1--* BuildingMetric
```

## State Machines

### InspectionSession
```
pending -> in_progress -> completed
                        -> cancelled
```

### Observation
Severity classification:
- info: Cosmetic or informational
- low: Minor issue, monitor
- medium: Needs attention, schedule service
- high: Requires prompt action
- critical: Immediate safety/operational risk

### MaintenanceTicket
```
open -> assigned -> in_progress -> resolved -> closed
                   \-> cancelled
```

## Invariants

- An inspection session must have at least one unit.
- A completed inspection session must have all required checkpoints completed.
- A maintenance ticket must reference either a source observation or be manually created.
- Building health score is computed daily from the most recent inspection data.
