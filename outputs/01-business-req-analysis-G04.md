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
| FR-01 | The system must store user information: user ID, full name, email, phone number, role, department, and account status. | High |
| FR-02 | The system must store space information: unique space code, space name, space type, building, floor, room number, capacity, current status, and usage policy. | High |
| FR-03 | The system must store the list of facilities available in each space (projector, whiteboard, microphone, computer, livestreaming equipment, air conditioner). | High |
| FR-04 | Users must be able to submit booking requests by selecting a space, requested start time, requested end time, purpose of use, and expected number of participants. | High |
| FR-05 | Booking types must include: lecture, examination, seminar, workshop, meeting, student activity, and administrative event. | Medium |
| FR-06 | Booking statuses must include: pending, approved, rejected, cancelled, checked in, completed, and no-show. | High |
| FR-07 | The system must prevent conflicting bookings — the same space cannot have two approved bookings with overlapping time periods. | High |
| FR-08 | A space that is under maintenance, temporarily closed, or retired cannot be booked. | High |
| FR-09 | When a booking is approved or rejected, the system must record the staff member who made the decision, the decision time, and a decision note. If rejected, the rejection reason must be stored. | High |
| FR-10 | At check-in, the system must record the actual start time, the person who checked in the booking, and the initial condition of the space. | Medium |
| FR-11 | At completion (check-out), the system must record the actual end time, the final condition of the space, and any usage notes. | Medium |
| FR-12 | The system must support maintenance records storing: related space, reporter, assigned staff member, problem description, start time, completion time, status, and result note. | High |
| FR-13 | A space under maintenance cannot be booked during the maintenance period. | High |
| FR-14 | Staff must be able to view booking history, upcoming bookings, spaces under maintenance, and no-show bookings. | Medium |

## Non-Functional Requirements

| ID | Requirement |
|---|---|
| NFR-01 | The system shall use Microsoft SQL Server as the database platform. |
| NFR-02 | Historical booking and maintenance data must be preserved indefinitely. |
| NFR-03 | Data integrity must be enforced through referential constraints at the database level. |
| NFR-04 | The system must support concurrent access by multiple users without data corruption. |
| NFR-05 | Queries must be designed for application integration with parameterized input. |

## Identified Entities

1. **User** — Person interacting with the system (student, lecturer, TA, staff, admin, manager)
2. **Space** — Physical room or area that can be booked
3. **Facility** — Equipment or amenity available in a space
4. **SpaceFacility** — Many-to-many link between Space and Facility
5. **Booking** — Request to use a space for a specific time period
6. **BookingApproval** — Decision record for booking approval or rejection
7. **CheckIn** — Record of check-in for a booking
8. **CheckOut** — Record of check-out/completion for a booking
9. **MaintenanceRecord** — Maintenance issue reported for a space

## Identified Relationships

- A **User** can submit many **Bookings** (1:N)
- A **Booking** is for exactly one **Space** (N:1)
- A **Booking** may have zero or one **BookingApproval** (1:0..1)
- A **Booking** may have zero or one **CheckIn** (1:0..1)
- A **Booking** may have zero or one **CheckOut** (1:0..1)
- A **Space** can contain many **Facilities** (M:N via SpaceFacility)
- A **Space** can have many **MaintenanceRecords** (1:N)
- A **User** (reporter) can report many **MaintenanceRecords** (1:N)
- A **User** (assigned staff) can be assigned many **MaintenanceRecords** (1:N)

## Assumptions

1. A booking can be checked in only if it has been approved.
2. A booking can be completed only if it has been checked in.
3. A single staff member handles each approval or rejection decision.
4. Space codes are unique identifiers assigned by the School.
5. Facility names follow a standardized vocabulary.
6. Each booking occurrence is a separate record — recurring bookings are not natively handled.
7. User roles are mutually exclusive (one user has exactly one role).
8. All timestamps use DATETIME2 in UTC.
9. A space under maintenance cannot have any approved/active bookings overlapping the maintenance period.

## Open Questions

1. Should the system support recurring booking patterns?
2. Is there a maximum or minimum booking duration?
3. Are automated email notifications required for approval/rejection?
4. Should maintenance tasks have priority levels?
5. How far in advance can a booking be made?
6. Should space usage policies be set per space type or per individual space?
