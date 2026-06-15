# Database Design Validation — Campus Space Management System

## Requirement Coverage Check

| Requirement | Covered By | Status |
|-------------|-----------|--------|
| R01: User account management | User table with account_status | ✓ |
| R02: Bookable space catalog | Space table with all descriptive fields | ✓ |
| R03: Facility/equipment tracking | Facility + SpaceFacility tables | ✓ |
| R04: Booking request submission | Booking table | ✓ |
| R05: Overlap prevention | Application/trigger enforcement on Booking | ✓* |
| R06: Unavailable space prevention | Application logic checking space status + overlap | ✓* |
| R07: Booking approval workflow | BookingApproval table | ✓ |
| R08: Check-in process | BookingSession (actual_start) | ✓ |
| R09: Completion/check-out process | BookingSession (actual_end) | ✓ |
| R10: Maintenance management | Maintenance table | ✓ |
| R11: Historical record keeping | No hard deletes; all tables append-only | ✓ |
| R12: Reporting capabilities | Query layer (07-query-design-G4.sql) | ✓ |

\* Requires application logic or a trigger — see gaps below.

## Business Rules Validation

| Rule | Validation |
|------|-----------|
| No overlapping approved bookings | Enforced by trigger or application — CHECK constraint alone cannot validate row-to-row interval overlap in SQL Server |
| Unavailable spaces cannot be booked | Application must check space.status NOT IN ('under_maintenance','temporarily_closed','retired') before insert |
| Approval decision must record staff, time, note | BookingApproval table has NOT NULL on staff_id, decision, decision_time; decision_note is nullable for approved cases |
| Check-in records actual start, who, initial condition | BookingSession has NOT NULL on actual_start and checked_in_by |
| Maintenance status lifecycle | CHECK constraint limits domain values but state transitions must be managed by application |
| History preservation | No ON DELETE CASCADE on any FK; all tables use IDENTITY and immutable PKs |

## Gaps and Assumptions

| Gap | Impact | Resolution |
|-----|--------|------------|
| Overlap detection requires procedural logic | DB cannot natively prevent overlaps with declarative constraints alone | Implement a trigger or application-level check before INSERT/UPDATE on Booking |
| No-show detection | The DB does not know the no-show threshold | Application logic marks no-show when current time > requested_start + threshold and status is still 'approved' |
| Capacity enforcement | The schema stores capacity but does not enforce it against expected_participants | Add CHECK (expected_participants <= (SELECT capacity FROM Space WHERE space_code = Booking.space_code)) in a trigger, or handle in application |
| Recurring bookings | Not supported in current schema | Would require a separate recurring_booking table or application-level expansion |
| User authentication | Assumed external; no password/hash fields | Acceptable per stated assumption |

## Limitations

- CHECK constraints on status columns do not enforce valid state _transitions_ (e.g., 'pending' -> 'approved' is valid, but 'completed' -> 'pending' is not). State machine logic must live in the application layer or in a trigger.
- The overlap-prevention trigger must handle concurrency (e.g., use SERIALIZABLE isolation or application-level locking).
- BookingSession combines check-in and check-out; if a booking is checked in but never completed, actual_end will remain NULL, which is handled correctly.
- Maintenance has two nullable FK references to User (reporter_id, assigned_to) — this matches the requirement that records may exist without a linked user.
