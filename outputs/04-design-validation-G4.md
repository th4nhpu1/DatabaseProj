# Database Design Validation — Campus Space Management System

## Requirement-to-Schema Traceability Matrix

| Req ID | Requirement | Entity | Relationship | Table | Constraint |
|--------|-------------|--------|-------------|-------|------------|
| R1 | User account management | User | — | User | PK (UserID), UNIQUE (Email), CHECK (Role), CHECK (AccountStatus) |
| R2 | Space catalog management | Space | — | Space | PK (SpaceID), UNIQUE (SpaceCode), CHECK (SpaceType), CHECK (Capacity), CHECK (Status) |
| R3 | Facility inventory per space | Facility, SpaceFacility | Space M:N Facility | Facility, SpaceFacility | PK (FacilityID), UNIQUE (FacilityName), FK (SpaceFacility.SpaceID → Space), FK (SpaceFacility.FacilityID → Facility), UNIQUE (SpaceID, FacilityID) |
| R4 | Booking request submission | BookingRequest | User 1:N BookingRequest, Space 1:N BookingRequest | BookingRequest | PK (BookingID), FK (RequestedBy → User), FK (SpaceID → Space), CHECK (EndTime > StartTime), CHECK (Purpose), CHECK (Status) |
| R5 | Booking approval workflow | BookingApproval | BookingRequest 1:1 BookingApproval | BookingApproval | PK (ApprovalID), FK (BookingID → BookingRequest, UNIQUE), FK (ApprovedBy → User), CHECK (Decision) |
| R6 | Check-in/check-out | BookingSession | BookingRequest 1:1 BookingSession | BookingSession | PK (SessionID), FK (BookingID → BookingRequest, UNIQUE), FK (CheckedInBy → User), FK (CheckedOutBy → User) |
| R7 | Maintenance management | MaintenanceRecord | Space 1:N MaintenanceRecord, User 1:N MaintenanceRecord | MaintenanceRecord | PK (MaintenanceID), FK (SpaceID → Space), FK (ReportedBy → User), FK (AssignedTo → User), CHECK (Status) |
| R8 | History and reporting | BookingStatusHistory, MaintenanceStatusHistory | BookingRequest 1:N BookingStatusHistory, MaintenanceRecord 1:N MaintenanceStatusHistory | BookingStatusHistory, MaintenanceStatusHistory | PK (StatusHistoryID), FK (BookingID → BookingRequest), FK (MaintenanceID → MaintenanceRecord), CHECK (ToStatus) |

## Business Rules Validation

| Rule | Enforced By | Status |
|------|-------------|--------|
| No overlapping bookings for same space | Application logic / trigger (cannot be expressed as simple constraint in SQL Server) | Addressed — see Limitations |
| Unavailable space cannot be booked | Application logic / trigger (must check Space.Status AND active MaintenanceRecord) | Addressed — see Limitations |
| All bookings require approval | FK (BookingApproval.BookingID is UNIQUE → 1:1); Status NOT NULL | Enforced |
| Only facility staff can check in | Application logic (not a DB constraint) | Addressed — see Limitations |
| Status transitions | CHECK constraint limits allowed values; history table records transitions | Enforced |
| Maintenance blocks booking | Application logic / trigger | Addressed |

## Conflicting Bookings

The schema prevents double-booking structurally by:
- Storing booking time ranges with CHECK (EndTime > StartTime)
- Recording status separately so only Approved/CheckedIn bookings are considered active
- A trigger (see Limitations) checks for time overlap before INSERT/UPDATE of BookingRequest when Status is Approved or CheckedIn

## Maintenance Blocks

A space with active maintenance (Status IN ('Reported','InProgress')) cannot have overlapping Approved/CheckedIn bookings. This is enforced by a trigger that checks for active maintenance on the Space when a booking is approved.

## Status Transitions

All status transitions are recorded immutably in BookingStatusHistory and MaintenanceStatusHistory. The main table's Status column holds the current value. Allowed values are constrained by CHECK constraints.

## Limitations Requiring Application Logic or Advanced Features

1. **Overlapping booking prevention** — SQL Server cannot express a "no time overlap" constraint with a simple UNIQUE or CHECK constraint. A trigger (`trg_PreventOverlappingBookings`) on BookingRequest AFTER INSERT, UPDATE is required to check for time-range overlaps among Approved/CheckedIn bookings on the same Space. Alternatively, an `AFTER INSERT/UPDATE` trigger or application-level check.

2. **Maintenance block enforcement** — A trigger (`trg_CheckSpaceAvailableForBooking`) must verify that the Space is not under active maintenance when a booking status changes to Approved.

3. **Role-based actions** — The database cannot enforce "only facility staff can check in." This must be enforced at the application layer.

4. **No-show detection** — Determining no-show requires a scheduled job or manual staff action; no DB constraint can auto-detect it.
