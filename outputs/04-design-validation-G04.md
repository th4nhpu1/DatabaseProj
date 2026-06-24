# Design Validation (Normalization) — Group 04

## Normalization Check Results

### User
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

### Space
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

### Facility
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

### SpaceFacility
- 1NF: ✓ — Atomic columns, composite PK
- 2NF: ✓ — quantity depends on full composite key (spaceCode + facilityId)
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

### Booking
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — userId and spaceCode are direct FKs, no transitive dependency
- **Final: 3NF**

### BookingApproval
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — All non-key columns depend only on bookingId
- **Final: 3NF**

### CheckIn
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

### CheckOut
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

### MaintenanceRecord
- 1NF: ✓ — Atomic columns, PK defined
- 2NF: ✓ — Single-column PK
- 3NF: ✓ — No transitive dependencies
- **Final: 3NF**

## Summary

All 9 tables satisfy 3NF. No decomposition required.

## Denormalization

Not applied. Normalized structure prevents update anomalies in a write-heavy system (bookings, approvals, check-in/out). Reporting queries can use indexed views without sacrificing base schema normalization.
