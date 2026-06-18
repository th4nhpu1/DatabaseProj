# Business Requirement Analysis — Campus Space Management System

## Business Purpose

The School of Computer Science manages shared physical spaces (auditoriums, classrooms, computer laboratories, project laboratories, meeting rooms, student workspaces) used for teaching, seminars, examinations, workshops, student projects, research activities, and academic events. The manual, ad-hoc process (email, phone, spreadsheets) has become unsustainable as activity volume grows. The system will provide a centralized database to manage space booking, approval, usage sessions, maintenance, incident reporting, and facility utilization.

## Stakeholders and User Roles

| Role | Description |
|------|-------------|
| Student | Books spaces for group work, projects, student activities |
| Lecturer | Books spaces for lectures, seminars, exams |
| Teaching Assistant | Books spaces on behalf of instructors |
| Facility Staff | Processes approvals, performs check-in/check-out, records maintenance |
| Department Administrator | Manages spaces, reviews utilization |
| Facility Manager | Oversees the entire system, resolves disputes |

## Main Business Processes

1. **Space Booking** — User selects space, time, purpose, submits request
2. **Booking Approval** — Facility staff/manager approves or rejects request
3. **Check-In** — Facility staff records actual start time and initial condition
4. **Check-Out (Completion)** — Facility staff records actual end time and final condition
5. **Maintenance Reporting** — User reports a problem; staff assigned to fix it
6. **History & Reporting** — Staff views booking history, upcoming bookings, maintenance records, no-shows

## Entities and Candidate Attributes

### User
UserID, FullName, Email, Phone, Role, Department, AccountStatus

### Space
SpaceID, SpaceCode, SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy

### Facility (lookup)
FacilityID, FacilityName

### SpaceFacility (junction)
SpaceFacilityID, SpaceID, FacilityID, Quantity

### BookingRequest
BookingID, RequestedBy, SpaceID, RequestedStartTime, RequestedEndTime, Purpose, ExpectedParticipants, Status

### BookingApproval
ApprovalID, BookingID, ApprovedBy, DecisionTime, Decision, DecisionNote, RejectionReason

### BookingSession (Check-In/Check-Out)
SessionID, BookingID, CheckedInBy, ActualStartTime, InitialCondition, CheckedOutBy, ActualEndTime, FinalCondition, UsageNotes

### BookingStatusHistory
StatusHistoryID, BookingID, FromStatus, ToStatus, ChangedBy, ChangedAt, Note

### MaintenanceRecord
MaintenanceID, SpaceID, ReportedBy, AssignedTo, ProblemDescription, StartTime, CompletionTime, Status, ResultNote

### MaintenanceStatusHistory
StatusHistoryID, MaintenanceID, FromStatus, ToStatus, ChangedBy, ChangedAt, Note

## Core Relationships and Cardinalities

| Entity A | Relationship | Entity B | Cardinality |
|----------|-------------|----------|-------------|
| User | Requests | BookingRequest | 1:N (one user makes many bookings) |
| Space | Is booked in | BookingRequest | 1:N (one space has many bookings) |
| BookingRequest | Has | BookingApproval | 1:1 (each booking has one approval decision) |
| BookingRequest | Has | BookingSession | 1:1 (each booking has one check-in session) |
| BookingRequest | Has history in | BookingStatusHistory | 1:N (each booking has many status changes) |
| Space | Has | SpaceFacility | 1:N (one space has many facility entries) |
| Facility | Appears in | SpaceFacility | 1:N (one facility can be in many spaces) |
| Space | Has | MaintenanceRecord | 1:N (one space has many maintenance records) |
| User | Reports | MaintenanceRecord | 1:N (one user reports many issues) |
| User | Is assigned to | MaintenanceRecord | 1:N (one user handles many issues) |
| User | Approves | BookingApproval | 1:N (one user approves many bookings) |

## Business Rules and Constraints

1. **Conflict prevention**: No two approved bookings may have overlapping time periods for the same space.
2. **Unavailable space**: A space under maintenance, temporarily closed, or retired cannot be booked.
3. **Approval required**: All booking requests require approval by facility staff or manager.
4. **Check-in by staff**: Only facility staff can perform check-in and check-out.
5. **Status values**: Pending → Approved/Rejected/Cancelled → CheckedIn → Completed/NoShow.
6. **No-show**: If a booking is not checked in, it transitions to NoShow after a threshold.
7. **Maintenance blocks booking**: A space with active maintenance (not completed) is unavailable for booking.
8. **Soft-delete**: Reference and space data use soft-delete (IsActive/DeletedAt).

## Assumptions

| # | Assumption | Type |
|---|------------|------|
| A1 | All booking requests require approval (the word "may" in the requirement is interpreted as "may be approved by either facility staff or manager," not "may optionally skip approval") | Minor |
| A2 | Booking status transitions are one-way forward; cancellations and no-shows cannot be reversed | Minor |
| A3 | Default booking duration limit is 8 hours per request | Minor |
| A4 | No-show threshold is 30 minutes past requested start time | Minor |
| A5 | Account status values are Active and Inactive | Minor |
| A6 | Maintenance status values are Reported, InProgress, Completed, Cancelled | Minor |
| A7 | Facilities are tracked as a shared lookup table with quantity per space | Minor |

## Open Questions

None. All ambiguities were resolved through minor assumptions above.

## Requirement Traceability

| Req ID | Description | Entities |
|--------|-------------|----------|
| R1 | User account management | User |
| R2 | Space catalog management | Space, SpaceFacility, Facility |
| R3 | Facility inventory per space | Facility, SpaceFacility |
| R4 | Booking request submission | BookingRequest |
| R5 | Booking approval workflow | BookingApproval |
| R6 | Check-in and check-out | BookingSession |
| R7 | Maintenance management | MaintenanceRecord, MaintenanceStatusHistory |
| R8 | History and reporting | BookingStatusHistory, MaintenanceStatusHistory |
