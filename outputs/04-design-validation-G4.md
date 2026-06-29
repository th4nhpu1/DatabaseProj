# Database Design Validation — Campus Space Management System

## Normalization Check

### 1NF (Atomic Values)
All tables satisfy 1NF. Every column contains atomic values — no multi-valued attributes or nested relations. SpaceFacility correctly decomposes the M:N relationship between Space and Facility.

### 2NF (Full Functional Dependency)
All tables satisfy 2NF. Tables with composite keys (SpaceFacility) have non-key attributes that depend on the full composite key. All other tables use single-column surrogate primary keys, so 2NF is trivially satisfied.

### 3NF (No Transitive Dependency)
All tables satisfy 3NF.

- **User:** All non-key attributes (full_name, email, phone, role, department, account_status) are directly dependent on user_id. No transitive dependencies exist.
- **Space:** All attributes depend directly on space_code. space_type is a classification attribute, not a determinant.
- **Booking:** user_id and space_code are FKs referencing User and Space. All other attributes depend directly on booking_id. No transitive dependency.
- **BookingApproval:** Depends on booking_id (via FK), which is a 1:1 extension of Booking.
- **BookingSession:** Similar to BookingApproval — 1:1 extension with no transitive dependencies.
- **Maintenance:** All attributes depend directly on maintenance_id. FK attributes (space_code, reporter_id, assigned_to) are direct dependencies.

**Conclusion:** All tables are in 3NF. No decomposition required.

## Requirement Traceability Matrix

| Req ID | Description | Entity | Table | Constraint |
|--------|-------------|--------|-------|------------|
| R01 | User account management | User | User | PK, CK(role), CK(account_status), UQ(email) |
| R02 | Bookable space catalog | Space | Space | PK, CK(space_type), CK(capacity > 0) |
| R03 | Facility/equipment tracking | Facility, SpaceFacility | Facility, SpaceFacility | PK, UQ(facility_name), PK(composite) |
| R04 | Booking request submission | Booking | Booking | PK, FK(User), FK(Space) |
| R05 | Overlap prevention | Booking | Booking | TRG_Booking_PreventOverlap |
| R06 | Unavailable space prevention | Space, Booking | Space, Booking | TRG_Booking_CheckSpaceAvailable |
| R07 | Capacity enforcement | Space, Booking | Space, Booking | TRG_Booking_CheckCapacity |
| R08 | Booking approval workflow | BookingApproval | BookingApproval | PK, FK, UQ(booking_id), CK(decision) |
| R09 | Check-in process | BookingSession | BookingSession | FK, NOT NULL(actual_start, checked_in_by) |
| R10 | Completion/check-out process | BookingSession | BookingSession | CK(actual_end > actual_start) |
| R11 | Maintenance management | Maintenance | Maintenance | PK, FK(Space, User x2), CK(status) |
| R12 | Historical record keeping | All | All tables | No ON DELETE CASCADE, audit columns |
| R13 | Soft-delete for reference data | User, Space | User, Space | IsActive BIT DEFAULT 1 |
| R14 | Audit trail | Transactional tables | Booking, BookingApproval, BookingSession, Maintenance | DEFAULT SYSUTCDATETIME(), TRG_ModifiedAt |

## Business Rules Validation

| Rule | Validation |
|------|-----------|
| No overlapping approved bookings | Trigger TRG_Booking_PreventOverlap rolls back INSERT/UPDATE causing overlap with existing confirmed bookings |
| Unavailable spaces cannot be booked | Trigger TRG_Booking_CheckSpaceAvailable rolls back INSERT/UPDATE when space.status is 'under_maintenance', 'temporarily_closed', or 'retired' |
| Capacity enforcement | Trigger TRG_Booking_CheckCapacity rolls back INSERT/UPDATE when expected_participants > space.capacity |
| Approval decision must record staff, time, note | BookingApproval table has NOT NULL on staff_id, decision, decision_time; decision_note is nullable for approved cases |
| Check-in records actual start, who, initial condition | BookingSession has NOT NULL on actual_start and checked_in_by |
| Maintenance status lifecycle | CHECK constraint limits domain values but state transitions must be managed by application |
| History preservation | No ON DELETE CASCADE on any FK; all tables use IDENTITY and immutable PKs |
| Soft-delete preservation | User and Space use IsActive flag; historical bookings remain resolvable via FK |

## Business Logic Validation

### Conditional/Optional Approvals (0-or-1 Relationships)
BookingApproval has a 1:0..1 relationship with Booking. This is enforced by:
- UNIQUE constraint on booking_id ensures at most one approval per booking.
- FK allows NULL (in the sense that no row exists until approval is made).
- The trigger TRG_Booking_PreventOverlap only fires for 'approved' or 'checked_in' status, so pending bookings do not trigger overlap checks.

### Multiple Overlapping Pending Requests
The schema allows multiple pending bookings for the same space with overlapping time ranges. This is by design:
- Overlap prevention only triggers when a booking transitions to 'approved' or 'checked_in'.
- Facility staff can see all pending requests and decide which to approve.
- When one request is approved, the next request that transitions to 'approved' will trigger the overlap prevention and be rejected.

## Gaps and Assumptions

| Gap | Impact | Resolution |
|-----|--------|------------|
| Overlap detection | DB cannot natively prevent overlaps with declarative constraints alone | TRG_Booking_PreventOverlap trigger implemented |
| Space unavailability | Cannot be enforced declaratively | TRG_Booking_CheckSpaceAvailable trigger implemented |
| Capacity enforcement | CHECK constraint cannot reference another table | TRG_Booking_CheckCapacity trigger implemented |
| No-show detection | DB does not know the no-show threshold | Application logic marks no-show when current time > requested_start + threshold and status is still 'approved' |
| Recurring bookings | Not supported in current schema | Would require a separate recurring_booking table or application-level expansion |
| User authentication | Assumed external; no password/hash fields | Acceptable per stated assumption (Structural) |

## Limitations Requiring Application Logic or Triggers

1. **Status State Machine:** CHECK constraints on status columns do not enforce valid state _transitions_ (e.g., 'pending' -> 'approved' is valid, but 'completed' -> 'pending' is not). State machine logic must live in the application layer or in additional triggers.
2. **Concurrent Overlap Checking:** The overlap-prevention trigger must handle concurrency (e.g., use SERIALIZABLE isolation or application-level locking).
3. **No-Show Automation:** The system cannot automatically mark no-shows — an application job must periodically check approved/checked_in bookings whose requested_start has passed.
4. **Soft-Delete Cascade:** When a User or Space is soft-deleted (IsActive = 0), existing FK references remain valid. The application should filter out inactive users/spaces when presenting options to users.
5. **ModifiedAt Audit:** The ModifiedAt audit triggers rely on AFTER UPDATE triggers on each transactional table, which adds minimal overhead but depends on trigger support.
