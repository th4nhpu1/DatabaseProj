# Logical Database Design — Campus Space Management System

## Relations with Attributes, Keys, and Constraints

### 1. `User`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| UserID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| FullName | NVARCHAR(100) | NOT NULL | |
| Email | NVARCHAR(255) | NOT NULL, UNIQUE | |
| PhoneNumber | NVARCHAR(20) | NULL | |
| Role | NVARCHAR(30) | NOT NULL, CHECK(IN('student','lecturer','teaching_assistant','facility_staff','department_administrator','facility_manager')) | |
| Department | NVARCHAR(100) | NULL | |
| AccountStatus | NVARCHAR(20) | NOT NULL, DEFAULT 'active', CHECK(IN('active','disabled','suspended')) | |
| IsActive | BIT | NOT NULL, DEFAULT 1 | Soft-delete flag |
| CreatedAt | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| ModifiedAt | DATETIME2 | NULL | Updated via trigger |

### 2. `Space`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| SpaceID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| SpaceCode | NVARCHAR(20) | NOT NULL, UNIQUE | Business key |
| SpaceName | NVARCHAR(100) | NOT NULL | |
| SpaceType | NVARCHAR(30) | NOT NULL, CHECK(IN('auditorium','classroom','computer_laboratory','project_laboratory','meeting_room','student_workspace')) | |
| Building | NVARCHAR(100) | NOT NULL | |
| Floor | NVARCHAR(10) | NOT NULL | |
| RoomNumber | NVARCHAR(20) | NOT NULL | |
| Capacity | INT | NOT NULL, CHECK(Capacity > 0) | |
| Status | NVARCHAR(30) | NOT NULL, DEFAULT 'available', CHECK(IN('available','in_use','under_maintenance','temporarily_closed','retired')) | |
| UsagePolicy | NVARCHAR(500) | NULL | Free-text policy |
| IsActive | BIT | NOT NULL, DEFAULT 1 | Soft-delete flag |
| CreatedAt | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| ModifiedAt | DATETIME2 | NULL | Updated via trigger |

### 3. `Facility`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| FacilityID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| FacilityName | NVARCHAR(100) | NOT NULL, UNIQUE | |
| Description | NVARCHAR(500) | NULL | |

### 4. `SpaceFacility`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| SpaceID | INT | PK, FK → Space(SpaceID) | |
| FacilityID | INT | PK, FK → Facility(FacilityID) | |

### 5. `BookingRequest`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| BookingID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| RequestedByUserID | INT | NOT NULL, FK → User(UserID) | |
| SpaceID | INT | NOT NULL, FK → Space(SpaceID) | |
| RequestedStartTime | DATETIME2 | NOT NULL, CHECK(RequestedEndTime > RequestedStartTime) | |
| RequestedEndTime | DATETIME2 | NOT NULL | |
| Purpose | NVARCHAR(500) | NOT NULL | Free-text purpose |
| PurposeType | NVARCHAR(30) | NOT NULL, CHECK(IN('lecture','examination','seminar','workshop','meeting','student_activity','administrative_event')) | |
| ExpectedParticipants | INT | NOT NULL, CHECK(ExpectedParticipants > 0) | |
| Status | NVARCHAR(20) | NOT NULL, DEFAULT 'pending', CHECK(IN('pending','approved','rejected','cancelled','checked_in','completed','no_show')) | |
| CreatedAt | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| ModifiedAt | DATETIME2 | NULL | Updated via trigger |

**Additional Constraints (application + table-valued function):**
- No two approved bookings can overlap on the same space (enforced via application and/or a filtered unique index on virtual columns).
- No booking for a space with non-completed maintenance overlapping the requested period (application-level check).

### 6. `BookingApproval`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| ApprovalID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| BookingID | INT | NOT NULL, FK → BookingRequest(BookingID), UNIQUE | 0..1 relationship |
| ApprovedByUserID | INT | NOT NULL, FK → User(UserID) | |
| DecisionTime | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| Decision | NVARCHAR(10) | NOT NULL, CHECK(IN('approved','rejected')) | |
| DecisionNote | NVARCHAR(500) | NULL | |
| RejectionReason | NVARCHAR(500) | NULL | Only when Decision = 'rejected' |

**Note:** The UNIQUE constraint on BookingID enforces at most one approval per booking (0 or 1).

### 7. `CheckIn`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| BookingID | INT | PK, FK → BookingRequest(BookingID) | 1:1 with BookingRequest |
| CheckedInByUserID | INT | NOT NULL, FK → User(UserID) | Facility staff |
| ActualStartTime | DATETIME2 | NOT NULL | |
| InitialCondition | NVARCHAR(500) | NULL | |

### 8. `CheckOut`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| BookingID | INT | PK, FK → BookingRequest(BookingID) | 1:1 with BookingRequest |
| CheckedOutByUserID | INT | NOT NULL, FK → User(UserID) | Facility staff |
| ActualEndTime | DATETIME2 | NOT NULL, CHECK(ActualEndTime > dbo.GetCheckInTime(BookingID)) | |
| FinalCondition | NVARCHAR(500) | NULL | |
| UsageNotes | NVARCHAR(1000) | NULL | |

### 9. `MaintenanceRecord`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| MaintenanceID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| SpaceID | INT | NOT NULL, FK → Space(SpaceID) | |
| ReportedByUserID | INT | NOT NULL, FK → User(UserID) | |
| AssignedToUserID | INT | NULL, FK → User(UserID) | May be unassigned initially |
| ProblemDescription | NVARCHAR(1000) | NOT NULL | |
| ProblemType | NVARCHAR(30) | NOT NULL, CHECK(IN('broken_projector','ac_failure','damaged_furniture','cleaning','network','other')) | |
| StartTime | DATETIME2 | NOT NULL | When problem started |
| CompletionTime | DATETIME2 | NULL | When resolved |
| Status | NVARCHAR(20) | NOT NULL, DEFAULT 'reported', CHECK(IN('reported','assigned','in_progress','completed','cancelled')) | |
| ResultNote | NVARCHAR(1000) | NULL | |
| CreatedAt | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| ModifiedAt | DATETIME2 | NULL | Updated via trigger |

### 10. `BookingStatusHistory`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| HistoryID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| BookingID | INT | NOT NULL, FK → BookingRequest(BookingID) | |
| PreviousStatus | NVARCHAR(20) | NULL | NULL for initial insert |
| NewStatus | NVARCHAR(20) | NOT NULL | |
| ChangedByUserID | INT | NOT NULL, FK → User(UserID) | Acting user |
| ChangedAt | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| Note | NVARCHAR(500) | NULL | |

### 11. `MaintenanceStatusHistory`
| Column | Type | Constraints | Notes |
|--------|------|------------|-------|
| HistoryID | INT | PK, IDENTITY(1,1) | Surrogate primary key |
| MaintenanceRecordID | INT | NOT NULL, FK → MaintenanceRecord(MaintenanceID) | |
| PreviousStatus | NVARCHAR(20) | NULL | NULL for initial insert |
| NewStatus | NVARCHAR(20) | NOT NULL | |
| ChangedByUserID | INT | NOT NULL, FK → User(UserID) | Acting user |
| ChangedAt | DATETIME2 | NOT NULL, DEFAULT SYSUTCDATETIME() | |
| Note | NVARCHAR(500) | NULL | |

## Mapping Notes from Conceptual Entities and Relationships

| ERD Relationship | Logical Implementation |
|-----------------|----------------------|
| User — submits — BookingRequest | FK `BookingRequest.RequestedByUserID` → `User.UserID` |
| User — decides — BookingApproval | FK `BookingApproval.ApprovedByUserID` → `User.UserID` |
| User — checks in — CheckIn | FK `CheckIn.CheckedInByUserID` → `User.UserID` |
| User — checks out — CheckOut | FK `CheckOut.CheckedOutByUserID` → `User.UserID` |
| User — reports — MaintenanceRecord | FK `MaintenanceRecord.ReportedByUserID` → `User.UserID` |
| User — assigned to — MaintenanceRecord | FK `MaintenanceRecord.AssignedToUserID` → `User.UserID` (nullable) |
| User — triggers status change — BookingStatusHistory | FK `BookingStatusHistory.ChangedByUserID` → `User.UserID` |
| Space — is booked in — BookingRequest | FK `BookingRequest.SpaceID` → `Space.SpaceID` |
| Space — contains — SpaceFacility | Composite FK `SpaceFacility.SpaceID` → `Space.SpaceID` |
| Space — undergoes — MaintenanceRecord | FK `MaintenanceRecord.SpaceID` → `Space.SpaceID` |
| Facility — installed in — SpaceFacility | Composite FK `SpaceFacility.FacilityID` → `Facility.FacilityID` |
| BookingRequest — may require — BookingApproval | FK + UNIQUE on `BookingApproval.BookingID` (0..1) |
| BookingRequest — has check-in — CheckIn | FK `CheckIn.BookingID` → `BookingRequest.BookingID` (1:0..1) |
| BookingRequest — has check-out — CheckOut | FK `CheckOut.BookingID` → `BookingRequest.BookingID` (1:0..1) |
| BookingRequest — records history — BookingStatusHistory | FK `BookingStatusHistory.BookingID` → `BookingRequest.BookingID` |
| MaintenanceRecord — records history — MaintenanceStatusHistory | FK `MaintenanceStatusHistory.MaintenanceRecordID` → `MaintenanceRecord.MaintenanceID` |

## Constraint Rationale for Booking and Maintenance History

- **BookingStatusHistory** captures every status transition for audit and dispute resolution. The `ChangedByUserID` ensures traceability — critical since the skill forbids hardcoding the acting user in triggers.
- **MaintenanceStatusHistory** similarly tracks lifecycle of maintenance tickets. Both history tables use surrogate PKs and foreign keys back to the parent entity.
- **No triggers for history insertion**: Per the skill's critical note, we do not use triggers to auto-populate history tables because determining the acting user in a trigger is unreliable. The application layer is responsible for inserting history records.
- **ModifiedAt triggers**: AFTER UPDATE triggers automatically set `ModifiedAt = SYSUTCDATETIME()` for all transactional tables.

## Convention Confirmation

| Convention | Applied | Notes |
|-----------|---------|-------|
| PascalCase naming | Yes | All tables and columns use PascalCase |
| Surrogate INT IDENTITY PKs | Yes | Every table has an IDENTITY PK |
| Natural keys as UNIQUE | Yes | SpaceCode (Space), Email (User), FacilityName (Facility) |
| Audit columns (CreatedAt, ModifiedAt) | Yes | On all transactional tables |
| History via dedicated tables | Yes | BookingStatusHistory, MaintenanceStatusHistory |
| Soft-delete for reference data | Yes | User.IsActive, Space.IsActive |
| Hard-delete for transient data | Yes | BookingRequest, etc. are hard-deleted if needed |
