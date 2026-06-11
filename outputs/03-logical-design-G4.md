# Logical Database Design

## Relations with Attributes

### User
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| UserID | INT | NOT NULL | PK, identity |
| FullName | NVARCHAR(100) | NOT NULL | |
| Email | NVARCHAR(255) | NOT NULL | UQ |
| Phone | NVARCHAR(20) | NULL | |
| Role | NVARCHAR(50) | NOT NULL | CHECK IN (Student, Lecturer, TA, FacilityStaff, DeptAdmin, FacilityManager) |
| Department | NVARCHAR(100) | NOT NULL | |
| AccountStatus | NVARCHAR(20) | NOT NULL | CHECK IN (Active, Inactive, Suspended), DEFAULT 'Active' |

### Space
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| SpaceCode | NVARCHAR(20) | NOT NULL | PK |
| SpaceName | NVARCHAR(100) | NOT NULL | |
| SpaceType | NVARCHAR(50) | NOT NULL | CHECK IN (Auditorium, Classroom, ComputerLab, ProjectLab, MeetingRoom, StudentWorkspace) |
| Building | NVARCHAR(100) | NOT NULL | |
| Floor | INT | NOT NULL | |
| RoomNumber | NVARCHAR(20) | NOT NULL | |
| Capacity | INT | NOT NULL | CHECK > 0 |
| CurrentStatus | NVARCHAR(30) | NOT NULL | CHECK IN (Available, InUse, UnderMaintenance, TemporarilyClosed, Retired) |
| UsagePolicy | NVARCHAR(MAX) | NULL | Free-text policy |

### Facility
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| FacilityID | INT | NOT NULL | PK, identity |
| FacilityName | NVARCHAR(100) | NOT NULL | UQ |

### SpaceFacility
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| SpaceCode | NVARCHAR(20) | NOT NULL | PK, FK → Space |
| FacilityID | INT | NOT NULL | PK, FK → Facility |
| Quantity | INT | NOT NULL | DEFAULT 1, CHECK > 0 |

### BookingRequest
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| BookingID | INT | NOT NULL | PK, identity |
| SpaceCode | NVARCHAR(20) | NOT NULL | FK → Space |
| RequesterID | INT | NOT NULL | FK → User |
| RequestedStartTime | DATETIME2 | NOT NULL | |
| RequestedEndTime | DATETIME2 | NOT NULL | CHECK > RequestedStartTime |
| Purpose | NVARCHAR(MAX) | NOT NULL | |
| ExpectedParticipants | INT | NOT NULL | CHECK > 0 |
| BookingType | NVARCHAR(50) | NOT NULL | CHECK IN (Lecture, Examination, Seminar, Workshop, Meeting, StudentActivity, AdminEvent) |
| Status | NVARCHAR(20) | NOT NULL | CHECK IN (Pending, Approved, Rejected, Cancelled, CheckedIn, Completed, NoShow), DEFAULT 'Pending' |

### Approval
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| ApprovalID | INT | NOT NULL | PK, identity |
| BookingID | INT | NOT NULL | FK → BookingRequest, UQ |
| StaffID | INT | NOT NULL | FK → User |
| DecisionTime | DATETIME2 | NOT NULL | DEFAULT GETDATE() |
| DecisionNote | NVARCHAR(MAX) | NULL | |
| RejectionReason | NVARCHAR(MAX) | NULL | Required when Decision = Rejected |

### Session
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| SessionID | INT | NOT NULL | PK, identity |
| BookingID | INT | NOT NULL | FK → BookingRequest, UQ |
| ActualStartTime | DATETIME2 | NULL | Set on check-in |
| ActualEndTime | DATETIME2 | NULL | Set on completion |
| CheckInBy | INT | NULL | FK → User |
| InitialCondition | NVARCHAR(MAX) | NULL | |
| FinalCondition | NVARCHAR(MAX) | NULL | |
| UsageNotes | NVARCHAR(MAX) | NULL | |

### Maintenance
| Column | Type | Nullable | Notes |
|--------|------|----------|-------|
| MaintenanceID | INT | NOT NULL | PK, identity |
| SpaceCode | NVARCHAR(20) | NOT NULL | FK → Space |
| ReporterID | INT | NOT NULL | FK → User |
| AssignedStaffID | INT | NULL | FK → User |
| ProblemDescription | NVARCHAR(MAX) | NOT NULL | |
| StartTime | DATETIME2 | NOT NULL | |
| CompletionTime | DATETIME2 | NULL | |
| Status | NVARCHAR(30) | NOT NULL | CHECK IN (Reported, InProgress, Completed, Cancelled), DEFAULT 'Reported' |
| ResultNote | NVARCHAR(MAX) | NULL | |

## Primary Keys and Foreign Keys Summary

| Table | Primary Key | Foreign Keys |
|-------|-------------|--------------|
| User | UserID | — |
| Space | SpaceCode | — |
| Facility | FacilityID | — |
| SpaceFacility | (SpaceCode, FacilityID) | SpaceCode → Space, FacilityID → Facility |
| BookingRequest | BookingID | SpaceCode → Space, RequesterID → User |
| Approval | ApprovalID | BookingID → BookingRequest, StaffID → User |
| Session | SessionID | BookingID → BookingRequest, CheckInBy → User |
| Maintenance | MaintenanceID | SpaceCode → Space, ReporterID → User, AssignedStaffID → User |

## Candidate Keys and Alternate Keys

- **User.Email** — candidate key (alternate unique key)
- **Facility.FacilityName** — candidate key (alternate unique key)
- **Approval.BookingID** — alternate key (1:1 with BookingRequest)
- **Session.BookingID** — alternate key (1:1 with BookingRequest)

## Nullability and Uniqueness Decisions

| Column | Nullable Rationale |
|--------|-------------------|
| User.Phone | Optional contact info |
| Approval.RejectionReason | Only required when rejected |
| Session.ActualStartTime | NULL until check-in occurs |
| Session.ActualEndTime | NULL until session completes |
| Session.CheckInBy | NULL until check-in |
| Session.*Condition | NULL until recorded |
| Maintenance.AssignedStaffID | NULL until assignment |
| Maintenance.CompletionTime | NULL until completed |
| Maintenance.ResultNote | NULL until resolved |

## Mapping Notes from Conceptual Entities/Relationships

| Conceptual Entity | Logical Relation | Notes |
|-------------------|-----------------|-------|
| User | User | Direct mapping |
| Space | Space | Direct mapping |
| Facility | Facility | Direct mapping |
| SpaceFacility (associative) | SpaceFacility | Resolves M:N |
| BookingRequest | BookingRequest | Direct mapping |
| Approval | Approval | 1:1 weak entity |
| Session | Session | 1:1 weak entity |
| Maintenance | Maintenance | Direct mapping |

## Constraint Rationale

- **Booking overlap prevention**: An application-level or indexed check (or a temporal exclusion constraint) is needed to prevent two approved bookings for the same space with overlapping time ranges. SQL Server does not natively support exclusion constraints; this is enforced via application logic or a trigger.
- **Maintenance blocks**: Application logic checks Space.CurrentStatus and active Maintenance records before allowing a new booking.
- **Status lifecycle**: BookingRequest.Status transitions are validated at the application layer (e.g., Pending → Approved → CheckedIn → Completed, or Pending → Rejected/Cancelled).
