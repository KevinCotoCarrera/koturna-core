# Koturna

**Building data layer for autonomous inspection.**

Koturna is a vertical SaaS platform for short-term rental property management. It provides a reliable foundation for inspections, property health monitoring, maintenance event tracking, inventory verification, and building digital twin data.

## Architecture

Koturna follows Domain-Driven Design with six bounded contexts:

| Context | Responsibility |
|---|---|
| **Identity** | Users, organizations, roles, permissions |
| **Properties** | Buildings, floors, units, assets, inventory |
| **Inspections** | Sessions, checkpoints, observations, media |
| **Maintenance** | Tickets, vendors, cost tracking |
| **Analytics** | Building health scores, risk metrics, time-series |
| **Fleet** (future) | Autonomous robot ingestion |
| **Privacy** (future) | Edge filtering, selective persistence |

## Tech Stack

- **Backend**: Elixir 1.19, Phoenix 1.8, LiveView 1.0
- **Database**: PostgreSQL (Neon serverless)
- **Jobs**: Oban (PostgreSQL-backed)
- **API**: JSON REST with OpenAPI (OpenApiSpex)
- **File Storage**: AWS S3 (ExAws)
- **Email**: Swoosh
- **Observability**: Telemetry, OpenTelemetry, PromEx, LoggerJSON

## Quick Start

### Prerequisites

- Elixir 1.19+
- A Neon PostgreSQL database (free tier works)

### Setup

```bash
# Copy environment config
cp .env.example .env
# Edit .env with your Neon database credentials

# Install dependencies and build assets
make setup
```

### Run

```bash
make dev
```

Server starts at http://localhost:4000.

### With Docker

```bash
make docker-up
```

## API

Versioned REST API at `/api/v1/`:

- `GET    /api/v1/buildings`
- `GET    /api/v1/units`
- `GET    /api/v1/inspections`
- `GET    /api/v1/observations`
- `GET    /api/v1/tickets`
- `GET    /api/v1/metrics`

OpenAPI spec at `/api/openapi.json`.

## Project Structure

```
lib/koturna/
├── identity/          # Users, orgs, memberships
├── properties/        # Buildings, floors, units, assets, inventory
├── inspections/       # Sessions, checkpoints, observations, media
├── maintenance/       # Tickets, vendors
├── analytics/         # Metrics, health scores, Oban jobs
├── fleet/             # Future robot ingestion (placeholder)
├── privacy/           # Future privacy/retention (placeholder)
└── events/            # Domain event system (PubSub)

lib/koturna_web/
├── controllers/api/   # REST API controllers
├── live/              # LiveView pages
└── components/        # Shared UI components
```

## Documentation

- [Architecture](docs/architecture.md) — DDD bounded contexts, tech decisions
- [Domain Model](docs/domain-model.md) — Entities, relationships, state machines
- [Event Catalog](docs/event-catalog.md) — Domain events via PubSub
- [Privacy Principles](docs/privacy-principles.md) — Selective persistence, data minimization
- [Future Robotics Roadmap](docs/future-robotics-roadmap.md) — Fleet layer plan

## Environment Variables

Copy `.env.example` to `.env` and configure with your Neon database URL:

```bash
cp .env.example .env
```

Required: `DATABASE_URL` (Neon connection string), `SECRET_KEY_BASE`.

## License

Proprietary. All rights reserved.
