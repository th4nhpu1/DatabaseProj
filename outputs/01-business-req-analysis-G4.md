# Business Requirement Analysis — Campus Space Management System

## Business Purpose
The School of Computer Science needs a database system to manage the booking and usage of shared campus spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, student workspaces). The system replaces the current manual process of email, phone, and spreadsheet-based scheduling.

## Stakeholders and User Roles

| Role | Description |
|------|-------------|
| Student | Books spaces for student projects and activities |
| Lecturer | Books spaces for teaching, examinations, workshops |
| Teaching Assistant | Assists with booking on behalf of courses |
| Facility Staff | Processes bookings, performs check-in/check-out, manages maintenance |
| Department Administrator | Oversees departmental space usage |
| Facility Manager | Manages overall facility operations, approves policies |

## Main Business Processes

1. **Space Booking** — A user selects a space, time slot, and purpose; the system must prevent overlapping approved bookings and block unavailable spaces.
2. **Booking Approval** — Facility staff or manager reviews and approves/rejects pending bookings; decision, time, and notes are recorded.
3. **Check-In** — Facility staff records actual start time, who performed check-in, and initial condition when the requester arrives.
4. **Check-Out / Completion** — Facility staff records actual end time, final condition, and usage notes when the session ends.
5. **Maintenance Management** — Maintenance records track problems, assignments, and resolution; spaces under maintenance cannot be booked.
6. **History & Reporting** — Staff can view booking history, upcoming bookings, spaces under maintenance, and no-show bookings.

## Candidate Entities and Attributes

| Entity | Audit Required | Soft-Delete | Candidate Attributes |
|--------|---------------|-------------|---------------------|
| User | No (reference) | Yes | user_id, full_name, email, phone, role, department, account_status |
| Space | No (reference) | Yes | space_code, space_name, space_type, building, floor, room_number, capacity, status, usage_policy |
| Facility | No (reference) | No | facility_id, facility_name |
| SpaceFacility | No (junction) | No | space_code, facility_id |
| Booking | Yes (transactional) | No | booking_id, requester, space, requested_start, requested_end, purpose, expected_participants, booking_type, status |
| BookingApproval | Yes (transactional) | No | approval_id, booking_id, staff_id, decision, decision_time, decision_note |
| BookingSession | Yes (transactional) | No | session_id, booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes |
| Maintenance | Yes (transactional) | No | maintenance_id, space, reporter, assigned_staff, problem_description, start_time, completion_time, status, result_note |

## Core Relationships and Cardinalities

- A **User** can submit many **Bookings** (1:N)
- A **Space** can have many **Bookings** (1:N)
- A **Booking** may have one **BookingApproval** (1:1 optional)
- A **Booking** may have one **BookingSession** (1:1 optional)
- A **Space** can have many **Facilities** and a **Facility** can belong to many Spaces (M:N via SpaceFacility)
- A **Space** can have many **Maintenance** records (1:N)
- A **User** can report many **Maintenance** records (1:N)
- A **User** can be assigned to many **Maintenance** records (1:N)

## Business Rules and Constraints

1. A space cannot have two approved bookings with overlapping time periods.
2. A space that is under maintenance, closed, or retired cannot be booked.
3. Expected participants must not exceed the space's capacity.
4. Booking statuses: pending, approved, rejected, cancelled, checked_in, completed, no-show.
5. Space statuses: available, in_use, under_maintenance, temporarily_closed, retired.
6. When a booking is approved/rejected, the decision must record the staff member, decision time, and note.
7. Check-in records actual start time, who checked in, and initial condition.
8. Completion records actual end time, final condition, and usage notes.
9. Maintenance statuses: reported, assigned, in_progress, completed, cancelled.
10. The system must preserve historical records (no hard delete of bookings or maintenance).

## Assumptions

| Assumption | Classification | Rationale |
|------------|---------------|-----------|
| User accounts and authentication are handled by an external university system; the database stores a reference copy of user data | Structural | Affects User table design — no password fields needed |
| Booking time slots are continuous (no predefined time blocks) | Minor | Simplifies scheduling logic; no time-slot lookup table |
| A booking is considered "no-show" if not checked in within a reasonable window (enforced by application logic, not DB constraints) | Minor | Threshold is configurable; DB only stores status |
| Approval is required for all bookings except those made by facility staff/manager | Structural | Affects the approval workflow logic |
| The same staff member can perform both approval and check-in for the same booking | Minor | No conflict-of-interest constraint in DB |
| Maintenance completion time is nullable until the work is finished | Minor | start_time is NOT NULL; completion_time is NULL until done |
| Capacity enforcement is a hard constraint checked at booking time | Structural | Requires trigger to compare expected_participants against Space.capacity |

## Open Questions / Ambiguities

- What is the exact no-show threshold (minutes after requested start)?
- Can a single booking span multiple days?
- Should the system support recurring bookings?
- What is the cancellation policy and who can cancel?
- Should there be a maximum booking duration per space type?
- Are there special approval workflows for high-capacity or restricted spaces?

## Requirement Traceability Matrix

| Req ID | Description | Entity | Table | Constraint Type |
|--------|-------------|--------|-------|-----------------|
| R01 | User account management | User | User | PK, CHECK(role), CHECK(account_status) |
| R02 | Bookable space catalog | Space | Space | PK, CHECK(space_type), CHECK(capacity > 0) |
| R03 | Facility/equipment tracking | Facility, SpaceFacility | Facility, SpaceFacility | PK, FK, UQ |
| R04 | Booking request submission | Booking | Booking | PK, FK(User, Space), CHECK(status) |
| R05 | Overlap prevention | Booking | Booking | Trigger TRG_Booking_PreventOverlap |
| R06 | Unavailable space prevention | Space, Booking | Space, Booking | Trigger TRG_Booking_CheckSpaceAvailable |
| R07 | Capacity enforcement | Space, Booking | Space, Booking | Trigger TRG_Booking_CheckCapacity |
| R08 | Booking approval workflow | BookingApproval | BookingApproval | PK, FK, UQ(booking_id), CHECK(decision) |
| R09 | Check-in process | BookingSession | BookingSession | FK, NOT NULL constraints |
| R10 | Completion/check-out process | BookingSession | BookingSession | CHECK(actual_end > actual_start) |
| R11 | Maintenance management | Maintenance | Maintenance | PK, FK(Space, User x2), CHECK(status) |
| R12 | Historical record keeping | All entities | All tables | No ON DELETE CASCADE, audit columns |
| R13 | Soft-delete for reference data | User, Space | User, Space | IsActive BIT DEFAULT 1 |
| R14 | Audit trail (CreatedAt/ModifiedAt) | Transactional tables | Booking, BookingApproval, BookingSession, Maintenance | DEFAULT SYSUTCDATETIME(), trigger on UPDATE |
