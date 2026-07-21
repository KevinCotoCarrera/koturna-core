# Koturna Privacy Principles

## Core Philosophy

Koturna is a building-health platform, NOT a surveillance system. Our architecture enforces this distinction at every layer.

## Principles

### 1. No Continuous Resident Surveillance
Koturna never records, stores, or processes continuous video of living spaces. All inspections are discrete, scheduled, and consented events.

### 2. Event-Only Retention
We retain inspection results, observations, and building metrics — not raw footage. Media references are pointers to files retained only for specific business purposes (damage documentation, compliance).

### 3. Purpose Limitation
Data collected during inspections serves exactly one purpose: building health assessment. Data is never repurposed for marketing, profiling, or unrelated analytics.

### 4. Edge Processing Assumption
When robot ingestion is activated, all video/visual processing occurs at the edge. Raw frames are ephemeral — processed into building-health events and immediately discarded.

### 5. Human Data Minimization
We do not collect, store, or process facial recognition, behavioral data, or personally identifiable resident information beyond what is necessary for inspection scheduling.

## Selective Persistence Architecture (Future)

When the fleet/robot layer is activated, the following pipeline will govern all data:

```
RawFrame -> [Edge AI Processing] -> BuildingEvent -> RetentionDecision -> (retain | discard)
                                                      |
                                              RedactedFrame (if anonymization needed)
```

### Data Classes

| Class | Description | Retention |
|---|---|---|
| **RawFrame** | Unprocessed robot camera frame | Ephemeral (< 5 min) |
| **RedactedFrame** | Frame with person data removed | 30 days (audit only) |
| **BuildingEvent** | Structural observation (crack, leak, temperature) | Permanent |
| **InspectionResult** | Human inspector's findings | Permanent |
| **Telemetry** | Sensor readings (temp, humidity, etc.) | Permanent |

### Discard Rules

The following data classes are ALWAYS discarded at the edge:
- Any frame containing identifiable persons (unless RedactedFrame with consent)
- Audio recordings
- License plate numbers
- Window-facing imagery that may capture neighboring properties

## Implementation Status

**Current**: Privacy layer exists as documented architecture placeholder (`lib/koturna/privacy/`). No video processing, frame storage, or robot integration is active.

**Future**: When robot ingestion is activated, privacy filtering will be required at the edge before any data enters the Koturna system.

## Compliance

This architecture is designed to comply with:
- GDPR (data minimization, purpose limitation)
- CCPA (right to know, right to delete)
- Local short-term rental regulations regarding surveillance

## Contact

Privacy inquiries: privacy@koturna.io
