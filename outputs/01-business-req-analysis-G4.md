# Business Requirement Analysis — Campus Space Management System

## Business Purpose

The School of Computer Science manages shared physical spaces (auditoriums, classrooms, computer labs, project labs, meeting rooms, student workspaces) used for teaching, seminars, examinations, workshops, student projects, research, and academic events. Currently, booking is handled manually via email, phone, or walk-in requests, with facility staff checking spreadsheets and shared calendars. As activity volume grows, this manual process is no longer sustainable. The School requires a database system to manage space booking, approvals, usage sessions, maintenance, incident reporting, and facility utilization in a structured, automated manner.

## Stakeholders and User Roles

| Role | Description |
|------|-------------|
| Student | Submits booking requests for student activities and project work |
| Lecturer | Submits booking requests for lectures, seminars, examinations |
| Teaching Assistant | Submits booking requests on behalf of lecturers or for tutorials |
| Facility Staff | Checks in/out bookings, performs maintenance, approves/rejects requests |
| Department Administrator | Oversees bookings for a department, may approve requests |
| Facility Manager | Manages spaces, facilities, maintenance schedules, approves/oversees all operations |

## Main Business Processes and Operational Goals

1. **Space Booking** — User selects a space, time slot, purpose; system checks availability and prevents conflicting approved bookings.
2. **Approval Workflow** — Booking requests may require manual approval (facility staff/manager). Some may be auto-approved depending on role/space.
3. **Check-In / Check-Out** — Facility staff records actual start/end times and space condition upon arrival and departure.
4. **Maintenance Management** — Problems are reported, assigned to staff, tracked to completion; spaces under maintenance cannot be booked.
5. **History & Audit** — All booking status changes and maintenance status changes are recorded historically.
6. **Reporting & Utilization** — Staff can view booking history, upcoming bookings, spaces under maintenance, no-shows, and utilization metrics.

## Entities and Candidate Attributes

### Core Entities

**User**
- UserID (PK), FullName, Email, PhoneNumber, Role, Department, AccountStatus, CreatedAt, ModifiedAt

**Space**
- SpaceID (PK), SpaceCode (UK), SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy, IsActive, CreatedAt, ModifiedAt

**Facility** (lookup)
- FacilityID (PK), FacilityName, Description

**SpaceFacility** (associative)
- SpaceID (FK), FacilityID (FK)

### Transactional Entities

**BookingRequest**
- BookingID (PK), RequestedByUserID (FK), SpaceID (FK), RequestedStartTime, RequestedEndTime, Purpose, PurposeType, ExpectedParticipants, Status, CreatedAt, ModifiedAt

**BookingApproval**
- ApprovalID (PK), BookingID (FK), ApprovedByUserID (FK), DecisionTime, Decision, DecisionNote, RejectionReason

**CheckIn**
- BookingID (PK,FK), CheckedInByUserID (FK), ActualStartTime, InitialCondition

**CheckOut**
- BookingID (PK,FK), CheckedOutByUserID (FK), ActualEndTime, FinalCondition, UsageNotes

**MaintenanceRecord**
- MaintenanceID (PK), SpaceID (FK), ReportedByUserID (FK), AssignedToUserID (FK), ProblemDescription, ProblemType, StartTime, CompletionTime, Status, ResultNote, CreatedAt, ModifiedAt

### History Entities

**BookingStatusHistory**
- HistoryID (PK), BookingID (FK), PreviousStatus, NewStatus, ChangedByUserID (FK), ChangedAt, Note

**MaintenanceStatusHistory**
- HistoryID (PK), MaintenanceRecordID (FK), PreviousStatus, NewStatus, ChangedByUserID (FK), ChangedAt, Note

## Core Relationships and Cardinalities

| Entity A | Relationship | Entity B | Cardinality | Notes |
|----------|-------------|----------|-------------|-------|
| User | submits → | BookingRequest | 1:N | A user may submit many requests |
| User | approves/rejects → | BookingApproval | 1:N | A staff member may approve/reject many bookings |
| User | checks in → | CheckIn | 1:N | A staff member performs check-ins |
| User | checks out → | CheckOut | 1:N | A staff member performs check-outs |
| User | reports → | MaintenanceRecord | 1:N | A user reports a problem |
| User | assigned to → | MaintenanceRecord | 1:N | Staff assigned to fix |
| Space | booked in → | BookingRequest | 1:N | A space has many booking requests |
| Space | has → | SpaceFacility | 1:N | A space has many facilities |
| Space | undergoes → | MaintenanceRecord | 1:N | A space may have multiple maintenance records |
| Facility | installed in → | SpaceFacility | 1:N | A facility may be in multiple spaces |
| BookingRequest | may have → | BookingApproval | 1:0..1 | Not all bookings need approval (conditional) |
| BookingRequest | has → | CheckIn | 1:0..1 | Only when user arrives |
| BookingRequest | has → | CheckOut | 1:0..1 | Only when session ends |
| BookingRequest | tracked by → | BookingStatusHistory | 1:N | All status changes recorded |
| MaintenanceRecord | tracked by → | MaintenanceStatusHistory | 1:N | All maintenance status changes recorded |

## Business Rules and Constraints

1. **Conflicting Bookings**: A space cannot have two approved bookings with overlapping time periods.
2. **Unavailable Spaces**: A space that is under maintenance, closed, or retired cannot be booked (checked at booking submission time and at approval time).
3. **Overlapping Pending Requests**: Multiple overlapping `Pending` requests for the same space are allowed. Only when a request moves to `Approved` does the conflict check become strict. This allows requesters to submit competing requests, with only one eventually being approved.
4. **Conditional Approval**: Some booking requests may skip manual approval — e.g., a lecturer booking their own designated classroom during standard teaching hours may be auto-approved. The schema must support optional approval (0 or 1 approval records per booking).
5. **Status Transitions**:
   - `Pending` → `Approved` (via approval or auto-approval)
   - `Pending` → `Rejected` (via manual rejection)
   - `Pending` → `Cancelled` (by requester)
   - `Approved` → `Cancelled` (by requester or staff, if not yet checked in)
   - `Approved` → `CheckedIn` (via check-in)
   - `CheckedIn` → `Completed` (via check-out)
   - `Approved` → `NoShow` (if not checked in by passed start time)
6. **History Logging**: Every status change on a BookingRequest or MaintenanceRecord triggers an insertion into the corresponding history table. The acting user must be captured.
7. **Maintenance blocks booking**: No booking can be created or approved for a time period that overlaps with an active (non-completed) maintenance record for that space.

## Assumptions

### Minor Assumptions (default and proceed)
- **A1**: Default booking duration is not specified; system will allow any duration constrained only by space availability.
- **A2**: Email and phone are optional contact fields for users.
- **A3**: PurposeType is stored as a lookup/enum value rather than free text (lecture, examination, seminar, workshop, meeting, student_activity, administrative_event).
- **A4**: ProblemType is stored as a lookup/enum (broken_projector, ac_failure, damaged_furniture, cleaning, network, other).
- **A5**: SpaceType values: auditorium, classroom, computer_laboratory, project_laboratory, meeting_room, student_workspace.
- **A6**: Role values: student, lecturer, teaching_assistant, facility_staff, department_administrator, facility_manager.
- **A7**: Space Status values: available, in_use, under_maintenance, temporarily_closed, retired.
- **A8**: Booking status values: pending, approved, rejected, cancelled, checked_in, completed, no_show.
- **A9**: Maintenance status values: reported, assigned, in_progress, completed, cancelled.
- **A10**: History tracking uses dedicated status history tables (not temporal tables) per project conventions.
- **A11**: ModifiedAt updates are handled via AFTER UPDATE triggers.
- **A12**: Soft-delete (IsActive) for Space and User tables; hard-delete for transactional data.
- **A13**: Vietnamese university context: Ho Chi Minh City University of Science campus naming.

### Structural Ambiguities (require user input before proceeding)
- **Q1**: What specific user roles/spaces qualify for auto-approval? Should this be configurable via a lookup table?
- **Q2**: How long after a booking's start time should the system wait before marking it as NoShow?
- **Q3**: Can a booking be partially checked in (e.g., multiple check-in sessions for multi-day bookings)?

## Open Questions
- **Q4**: Should the system support recurring bookings (e.g., weekly lectures for a semester)?
- **Q5**: Is there a maximum advance booking window?

## Requirement Traceability Notes

| Req # | Requirement Summary | Entity | Relationship |
|-------|-------------------|--------|-------------|
| R1 | User account management | User | — |
| R2 | Space catalog | Space, SpaceFacility, Facility | Space-Facility |
| R3 | Booking request submission | BookingRequest | User→BookingRequest, Space→BookingRequest |
| R4 | Prevent conflicting bookings | BookingRequest | Business rule (application + constraint) |
| R5 | Approval workflow | BookingApproval | BookingRequest→BookingApproval |
| R6 | Check-in / Check-out | CheckIn, CheckOut | BookingRequest→CheckIn/CheckOut |
| R7 | Maintenance management | MaintenanceRecord | Space→MaintenanceRecord, User→MaintenanceRecord |
| R8 | History preservation | BookingStatusHistory, MaintenanceStatusHistory | BookingRequest→History, MaintenanceRecord→History |
| R9 | Facility inventory | Facility, SpaceFacility | Space→SpaceFacility→Facility |
