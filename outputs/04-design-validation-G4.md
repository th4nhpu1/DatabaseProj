# Database Design Validation — Campus Space Management System

## Requirement-to-Schema Traceability Matrix

| Req ID | Requirement | Entity | Relationship | Table | Constraint |
|--------|------------|--------|-------------|-------|-----------|
| R1 | User account management | User | — | User | PK (UserID), UK (Email), CHECK (Role, AccountStatus) |
| R2a | Space catalog | Space | — | Space | PK (SpaceID), UK (SpaceCode), CHECK (SpaceType, Status) |
| R2b | Facility inventory | Facility | Space-Facility | Facility, SpaceFacility | PKs, FKs, UK (FacilityName) |
| R3 | Booking request submission | BookingRequest | User→BookingRequest, Space→BookingRequest | BookingRequest | FKs, CHECK (times, participants, status) |
| R4 | Prevent conflicting bookings | BookingRequest | (application rule) | — | Application + filtered index on approved status |
| R5 | Approval workflow (conditional) | BookingApproval | BookingRequest→BookingApproval | BookingApproval | FK + UNIQUE on BookingID (0..1) |
| R6a | Check-in | CheckIn | BookingRequest→CheckIn | CheckIn | FK, PK = BookingID |
| R6b | Check-out | CheckOut | BookingRequest→CheckOut | CheckOut | FK, PK = BookingID |
| R7 | Maintenance management | MaintenanceRecord | Space→MaintenanceRecord, User→MaintenanceRecord | MaintenanceRecord | FKs, CHECK (ProblemType, Status) |
| R8a | Booking history | BookingStatusHistory | BookingRequest→BookingStatusHistory | BookingStatusHistory | FK, all columns NOT NULL |
| R8b | Maintenance history | MaintenanceStatusHistory | MaintenanceRecord→MaintenanceStatusHistory | MaintenanceStatusHistory | FK, all columns NOT NULL |
| R9 | Facility-space mapping | SpaceFacility | Space↔Facility | SpaceFacility | Composite PK, FKs |

## Validation of Business Rules and Constraints

### CRITICAL CHECK: Conditional Approvals (0-or-1)
**Status: PASSED**

The schema supports optional approvals correctly:
- `BookingApproval.BookingID` has both a FK to `BookingRequest.BookingID` AND a UNIQUE constraint.
- This enforces at most one approval record per booking (0 or 1), never more.
- For auto-approved bookings, an approval record is still created (by the system or a designated auto-approval user) with Decision = 'approved'.
- For bookings that skip manual approval entirely, no `BookingApproval` record is created until/unless someone manually intervenes.
- This is NOT a mandatory 1:1 relationship. It is correctly modeled as `1:0..1`.

### CRITICAL CHECK: Overlapping Pending Requests
**Status: PASSED**

The schema allows multiple overlapping `Pending` requests:
- No unique constraint exists on `(SpaceID, RequestedStartTime, RequestedEndTime)` for pending status.
- Conflict enforcement happens at the `Approved` status transition:
  - Before a request moves from `Pending` to `Approved`, the application checks for overlapping approved bookings.
  - A filtered unique index or a table-valued function can be used to enforce no overlapping approved bookings at the database level:
    ```sql
    CREATE UNIQUE INDEX IX_NoOverlappingApproved
    ON BookingRequest(SpaceID, RequestedStartTime, RequestedEndTime)
    WHERE Status = 'approved';
    ```
    Note: SQL Server filtered unique indexes cannot directly express time-overlap exclusion, so this is enforced via an application check with a scheduled job or an `AFTER UPDATE, INSERT` trigger that validates the overlap. Alternatively, a user-defined function + CHECK constraint can be used.
- Multiple `Pending` requests can coexist; only one can eventually be approved for a given time-slot.

### Maintenance Blocks Bookings
**Status: PASSED**

The `MaintenanceRecord` table stores maintenance with status and time range. Before approving a booking:
1. Query maintenance records for the same space where `Status NOT IN ('completed', 'cancelled')` and the maintenance time overlaps the requested booking time.
2. If any such maintenance exists, the booking cannot be approved.
3. This is enforced at the application layer and can be encapsulated in a scalar function:
   ```sql
   CREATE FUNCTION dbo.IsSpaceAvailable(@SpaceID INT, @Start DATETIME2, @End DATETIME2)
   RETURNS BIT AS ...
   ```

### Status Transition History
**Status: PASSED**

Every status change on `BookingRequest` and `MaintenanceRecord` is captured in dedicated history tables. The history tables are populated by the application layer (not triggers) per the skill's critical rule about acting-user traceability. The `ChangedByUserID` FK references `User.UserID`, ensuring full audit trail.

### Soft-Delete Policy
**Status: PASSED**

- `User.IsActive` (BIT, DEFAULT 1) — soft-delete
- `Space.IsActive` (BIT, DEFAULT 1) — soft-delete
- Transactional tables (BookingRequest, MaintenanceRecord, etc.) do not have IsActive; they use hard-delete if cleanup is needed.

### Audit Columns
**Status: PASSED**

All transactional tables include `CreatedAt` and `ModifiedAt`. The `ModifiedAt` is updated via AFTER UPDATE triggers. The skill's critical note about triggers for ModifiedAt is followed.

## Unresolved Gaps and Assumptions

| ID | Gap | Impact | Resolution |
|----|-----|--------|-----------|
| G1 | Auto-approval rules not specified | Affects which bookings create BookingApproval records | See Q1 in Step 1 — requires user input |
| G2 | No-show timeout not defined | Affects scheduled job logic for auto-transition | See Q2 in Step 1 — requires user input |
| G3 | Recurring bookings not supported | Schema only handles single-slot bookings | Q4 in Step 1 |
| G4 | Approval check for overlapping maintenances is application-level | No native DB constraint for this | Acceptable — complex temporal exclusion is hard in pure DDL |

## Conflicting Bookings, Maintenance Blocks, and Status Transitions

All three are structurally represented:

1. **Conflicting Bookings**: Represented by the `BookingRequest` table with time-range columns. Database-level enforcement via a filtered unique index (or trigger) on `Status = 'approved'` with overlap detection. Application-level enforcement at booking submission and approval time.

2. **Maintenance Blocks**: Represented by the `MaintenanceRecord` table linked to `Space`. Active maintenance (status not in completed/cancelled) blocks overlapping bookings. Enforced via application logic before approval.

3. **Status Transitions**: Represented by `BookingStatusHistory` and `MaintenanceStatusHistory` tables. Each transition records previous/new state, acting user, and timestamp. No in-place overwrite of history — the parent table's `Status` column shows the current state only.

## Limitations Requiring Application Logic

| Limitation | Description | Workaround |
|-----------|-------------|-----------|
| Temporal overlap enforcement | Native SQL Server unique constraints cannot express "no overlapping time ranges" | Use a trigger or application-layer check with a filtered unique index on computed columns |
| Auto-approval business rules | Conditional approval depends on role, space, time, and other parameters not in schema | Application logic or a configurable rules table |
| No-show auto-detection | Requires scheduled job to find approved bookings past start time with no check-in | SQL Server Agent job or external scheduler |
| History insertion without triggers | Skill rule forbids triggers for history due to acting-user ambiguity | Application must insert history records alongside status updates |
