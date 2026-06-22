# Design Validation (Normalization) — Group 04

## Normalization Check

All tables from the logical design are verified against 1NF, 2NF, and 3NF.

### User

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | All columns atomic, PK defined |
| 2NF | ✓ | Single-column PK, no partial dependencies |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

### Space

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

### Facility

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

### SpaceFacility

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, composite PK |
| 2NF | ✓ | quantity depends on full composite key |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

### Booking

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | userId and spaceCode are direct FKs (no transitive dependency) |
| **Final** | **3NF** | |

### BookingApproval

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | All non-key columns depend only on bookingId |
| **Final** | **3NF** | |

### CheckIn

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

### CheckOut

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

### MaintenanceRecord

| NF | Status | Reasoning |
|---|---|---|
| 1NF | ✓ | Atomic columns, PK defined |
| 2NF | ✓ | Single-column PK |
| 3NF | ✓ | No transitive dependencies |
| **Final** | **3NF** | |

## Summary

All 9 tables satisfy 3NF. No decomposition is required.

## Denormalization Decision

Denormalization was not applied because:
- Query patterns (conflict detection, availability checks, booking history) can be served efficiently with proper indexing.
- Normalized structure prevents update anomalies in a write-heavy system (bookings, approvals, check-in/out).
- Reporting queries can use views or indexed views without sacrificing the normalized base schema.

## Assumptions

1. The `role` attribute in `User` is stored as a string rather than a lookup table because the set of roles is fixed and small. This is a design choice that does not violate 3NF.
2. No table has multiple candidate keys, so BCNF analysis is not required.
