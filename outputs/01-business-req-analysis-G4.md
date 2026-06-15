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

| Entity | Candidate Attributes |
|--------|---------------------|
| User | user_id, full_name, email, phone, role, department, account_status |
| Space | space_code, space_name, space_type, building, floor, room_number, capacity, status, usage_policy |
| Facility | facility_id, facility_name |
| SpaceFacility | space_code, facility_id |
| Booking | booking_id, requester, space, requested_start, requested_end, purpose, expected_participants, booking_type, status, created_at |
| BookingApproval | booking_id, staff_id, decision, decision_time, decision_note |
| BookingSession | booking_id, actual_start, checked_in_by, initial_condition, actual_end, final_condition, usage_notes |
| Maintenance | maintenance_id, space, reporter, assigned_staff, problem_description, start_time, completion_time, status, result_note |

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
3. Booking statuses: pending, approved, rejected, cancelled, checked_in, completed, no-show.
4. Space statuses: available, in_use, under_maintenance, temporarily_closed, retired.
5. When a booking is approved/rejected, the decision must record the staff member, decision time, and note.
6. Check-in records actual start time, who checked in, and initial condition.
7. Completion records actual end time, final condition, and usage notes.
8. Maintenance statuses: reported, assigned, in_progress, completed, cancelled.
9. The system must preserve historical records (no hard delete of bookings or maintenance).

## Assumptions

- User accounts and authentication are handled by an external university system; the database stores a reference copy of user data.
- Booking time slots are continuous (no predefined time blocks).
- A booking is considered "no-show" if not checked in within a reasonable window (enforced by application logic, not DB constraints).
- Approval is required for all bookings except those made by facility staff/manager (enforced by application logic).
- The same staff member can perform both approval and check-in for the same booking.
- Maintenance completion time is nullable until the work is finished.

## Open Questions / Ambiguities

- What is the exact no-show threshold (minutes after requested start)?
- Can a single booking span multiple days?
- Are there any capacity-based restrictions (e.g., max participants must not exceed room capacity)?
- Should the system support recurring bookings?
- What is the cancellation policy and who can cancel?

## Requirement Traceability

| Req # | Description | Entity |
|-------|-------------|--------|
| R01 | User account management | User |
| R02 | Bookable space catalog | Space, SpaceFacility |
| R03 | Facility/equipment tracking | Facility, SpaceFacility |
| R04 | Booking request submission | Booking |
| R05 | Overlap prevention | Booking (constraint) |
| R06 | Unavailable space prevention | Booking (constraint) |
| R07 | Booking approval workflow | BookingApproval |
| R08 | Check-in process | BookingSession |
| R09 | Completion/check-out process | BookingSession |
| R10 | Maintenance management | Maintenance |
| R11 | Historical record keeping | All entities |
| R12 | Reporting (history, upcoming, maintenance, no-show) | Query layer |
