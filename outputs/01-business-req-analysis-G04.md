# Business Requirement Analysis — Group 04

## Project Name
School Space Booking and Facility Management System

## Date
2026-06-22

## Stakeholders

| Stakeholder | Role | Interest |
|---|---|---|
| Facility Manager | System Owner | Overall oversight, utilization reporting |
| Facility Staff | Operator | Process bookings, check-in/check-out, maintenance |
| Lecturers | End User | Book spaces for teaching and exams |
| Teaching Assistants | End User | Book spaces for tutorials and labs |
| Students | End User | Book student workspaces and project labs |
| Department Administrators | End User | Manage bookings for their department |
| IT Support | End User | Report and resolve facility issues |

## Functional Requirements

| ID | Description | Priority |
|---|---|---|
| FR-01 | System must store user information: user ID, full name, email, phone number, role, department, account status. | High |
| FR-02 | System must store space information: unique space code, space name, space type, building, floor, room number, capacity, current status, usage policy. | High |
| FR-03 | System must store facilities available in each space (projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner). | High |
| FR-04 | Users must submit booking requests with space, requested start/end time, purpose, expected participants. | High |
| FR-05 | Booking types must include: lecture, examination, seminar, workshop, meeting, student activity, administrative event. | Medium |
| FR-06 | Booking statuses must include: pending, approved, rejected, cancelled, checked in, completed, no-show. | High |
| FR-07 | Same space cannot have two approved bookings with overlapping time periods. | High |
| FR-08 | Space under maintenance, closed, or retired cannot be booked. | High |
| FR-09 | Approval/rejection must record decision-maker, decision time, decision note; rejection reason if rejected. | High |
| FR-10 | Check-in must record actual start time, check-in person, initial space condition. | Medium |
| FR-11 | Completion must record actual end time, final condition, usage notes. | Medium |
| FR-12 | Maintenance records must store: space, reporter, assigned staff, problem description, start/completion time, status, result note. | High |
| FR-13 | Space under maintenance must not be bookable during maintenance period. | High |
| FR-14 | Staff must view booking history, upcoming bookings, spaces under maintenance, no-show bookings. | Medium |

## Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-01 | Microsoft SQL Server as database platform. |
| NFR-02 | Historical booking and maintenance data preserved indefinitely. |
| NFR-03 | Data integrity enforced through referential constraints at database level. |
| NFR-04 | Concurrent access by multiple users without data corruption. |
| NFR-05 | Queries designed for application integration with parameterized input. |

## Entities

1. **User** — Person interacting with the system
2. **Space** — Physical room or area that can be booked
3. **Facility** — Equipment or amenity available in a space
4. **SpaceFacility** — Many-to-many link between Space and Facility
5. **Booking** — Request to use a space for a specific time period
6. **BookingApproval** — Decision record for booking approval or rejection
7. **CheckIn** — Record of check-in for a booking
8. **CheckOut** — Record of check-out/completion
9. **MaintenanceRecord** — Maintenance issue reported for a space

## Relationships

- **User** → **Booking** (1:N) — A user submits many bookings
- **Booking** → **Space** (N:1) — A booking is for one space
- **Booking** → **BookingApproval** (1:0..1) — A booking may have an approval decision
- **Booking** → **CheckIn** (1:0..1) — A booking may have a check-in record
- **Booking** → **CheckOut** (1:0..1) — A booking may have a check-out record
- **Space** ⟷ **Facility** (M:N) — A space can contain many facilities via SpaceFacility
- **Space** → **MaintenanceRecord** (1:N) — A space can have many maintenance records
- **User** (reporter) → **MaintenanceRecord** (1:N) — A user reports maintenance
- **User** (assignee) → **MaintenanceRecord** (1:N) — A user is assigned maintenance tasks

## Assumptions

1. Booking can be checked in only after approval.
2. Booking can be completed only after check-in.
3. Single staff member handles each approval/rejection.
4. Space codes are unique identifiers assigned by the School.
5. Facility names follow standardized vocabulary.
6. Each booking occurrence is a separate record; recurring bookings not natively handled.
7. User roles are mutually exclusive.
8. All timestamps use DATETIME2 in UTC.

## Open Questions

1. Recurring booking support needed?
2. Maximum/minimum booking duration?
3. Automated email notifications required?
4. Maintenance priority levels needed?
5. Advance booking horizon limit?
6. Usage policies per space type or per individual space?
