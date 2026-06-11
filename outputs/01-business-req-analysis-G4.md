# Business Requirement Analysis

## Business Purpose

The School of Computer Science needs a database system to manage the booking and usage of shared campus spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, and student workspaces). The current manual process (email, phone, spreadsheets) is no longer sustainable as the volume of classes, projects, workshops, seminars, and events grows.

## Stakeholders and User Roles

| Role | Description |
|------|-------------|
| Student | Books spaces for study, projects, or student activities |
| Lecturer | Books spaces for lectures, seminars, examinations |
| Teaching Assistant | Books spaces for tutorials or lab sessions |
| Facility Staff | Manages bookings, check-in/check-out, maintenance records |
| Department Administrator | Oversees scheduling and approvals |
| Facility Manager | Oversees the system, resolves conflicts, manages maintenance |

## Main Business Processes and Operational Goals

1. **Space Booking** — Users submit booking requests; staff approve or reject them.
2. **Check-in / Check-out** — Facility staff record actual start/end times and space condition.
3. **Maintenance Management** — Report problems, assign staff, track completion.
4. **Conflict Prevention** — No overlapping approved bookings for the same space.
5. **History & Reporting** — View booking history, upcoming bookings, no-shows, utilization.

## Entities and Candidate Attributes

| Entity | Candidate Attributes |
|--------|---------------------|
| User | UserID, FullName, Email, Phone, Role, Department, AccountStatus |
| Space | SpaceCode, SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, CurrentStatus, UsagePolicy |
| Facility | FacilityID, FacilityName (per space) |
| BookingRequest | BookingID, SpaceID, RequesterID, StartTime, EndTime, Purpose, Participants, BookingType, Status |
| Approval | ApprovalID, BookingID, StaffID, DecisionTime, DecisionNote, RejectionReason |
| Session | SessionID, BookingID, ActualStartTime, ActualEndTime, CheckInBy, InitialCondition, FinalCondition, UsageNotes |
| Maintenance | MaintenanceID, SpaceID, ReporterID, AssignedStaffID, ProblemDesc, StartTime, CompletionTime, Status, ResultNote |

## Core Relationships and Cardinalities

- A **User** may submit many **BookingRequests** (1:N)
- A **Space** may have many **BookingRequests** (1:N)
- A **BookingRequest** may have one **Approval** (1:1)
- A **BookingRequest** may have one **Session** (1:1)
- A **Space** may have many **Facilities** (1:N)
- A **User** may report many **Maintenance** records (1:N)
- A **Space** may have many **Maintenance** records (1:N)

## Business Rules and Constraints

1. **No overlapping bookings** — Two approved bookings cannot have overlapping time ranges for the same space.
2. **Unavailable spaces cannot be booked** — Spaces under maintenance, closed, or retired are not bookable.
3. **Maintenance blocks bookings** — If a space is under active maintenance, new bookings for overlapping periods are rejected.
4. **Booking status lifecycle**: Pending → Approved/Rejected/Cancelled → CheckedIn → Completed/No-Show.
5. **Approval required** — Every booking requires approval by facility staff or manager.
6. **Rejection requires a reason** — When a booking is rejected, the rejection reason is mandatory.
7. **Check-in / Check-out** — Facility staff must record actual times and space condition.
8. **Account status** — Inactive users cannot submit bookings (application-level rule).

## Assumptions

1. The system does not handle recurring bookings; each booking is a single time slot.
2. Approval is always required, even if the requester is facility staff.
3. A space can have multiple facilities, and the same facility type can appear in multiple spaces (many-to-many mapped via a junction table).
4. Maintenance status is tracked per record; a space is unavailable if it has any open (non-completed) maintenance record.
5. The system does not automatically assign staff to maintenance; assignment is manual.
6. User authentication is handled externally (existing university account system).
7. Booking cancellation can be requested by the original requester or by staff.
8. No-show status is set by facility staff when the requester does not arrive within a reasonable time.

## Open Questions / Ambiguities

1. What is the exact time window for marking a booking as no-show?
2. Should the system support recurring booking patterns (e.g., weekly lectures)?
3. What is the maximum booking duration per request?
4. Should there be different approval workflows depending on space type or requester role?
5. How far in advance can a booking be made?
6. Should notification (email/SMS) be part of the database schema or handled by application logic?

## Requirement Traceability Notes

Requirement source: `req/business-requirement.md` (School of Computer Science Facility Manager summary).
PDF (`CS486_Project.pdf`) could not be read; no discrepancies identified. If the PDF contains additional requirements, they should be incorporated after review.
