# Logical Database Design — Campus Space Management System

## Relations and Attributes

All tables use **PascalCase** naming. Surrogate integer `IDENTITY` primary keys are used throughout.

### User
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| UserID | int | NOT NULL | PK, IDENTITY(1,1) |
| FullName | nvarchar(100) | NOT NULL | |
| Email | nvarchar(255) | NOT NULL | UNIQUE |
| Phone | nvarchar(20) | NULL | |
| Role | nvarchar(30) | NOT NULL | CHECK (Role IN ('Student','Lecturer','TeachingAssistant','FacilityStaff','DepartmentAdministrator','FacilityManager')) |
| Department | nvarchar(100) | NOT NULL | |
| AccountStatus | nvarchar(20) | NOT NULL | DEFAULT 'Active', CHECK (AccountStatus IN ('Active','Inactive')) |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |
| IsActive | bit | NOT NULL | DEFAULT 1 |
| DeletedAt | datetime2 | NULL | |

**Delete policy**: Soft-delete (IsActive, DeletedAt)

### Space
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| SpaceID | int | NOT NULL | PK, IDENTITY(1,1) |
| SpaceCode | nvarchar(20) | NOT NULL | UNIQUE |
| SpaceName | nvarchar(100) | NOT NULL | |
| SpaceType | nvarchar(30) | NOT NULL | CHECK (SpaceType IN ('Auditorium','Classroom','ComputerLaboratory','ProjectLaboratory','MeetingRoom','StudentWorkspace')) |
| Building | nvarchar(100) | NOT NULL | |
| Floor | int | NOT NULL | |
| RoomNumber | nvarchar(20) | NOT NULL | |
| Capacity | int | NOT NULL | CHECK (Capacity > 0) |
| Status | nvarchar(30) | NOT NULL | DEFAULT 'Available', CHECK (Status IN ('Available','InUse','UnderMaintenance','TemporarilyClosed','Retired')) |
| UsagePolicy | nvarchar(500) | NULL | |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |
| IsActive | bit | NOT NULL | DEFAULT 1 |
| DeletedAt | datetime2 | NULL | |

**Delete policy**: Soft-delete (IsActive, DeletedAt)

### Facility
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| FacilityID | int | NOT NULL | PK, IDENTITY(1,1) |
| FacilityName | nvarchar(100) | NOT NULL | UNIQUE |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |

**Delete policy**: Soft-delete not needed — transient lookup data.

### SpaceFacility
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| SpaceFacilityID | int | NOT NULL | PK, IDENTITY(1,1) |
| SpaceID | int | NOT NULL | FK → Space.SpaceID |
| FacilityID | int | NOT NULL | FK → Facility.FacilityID |
| Quantity | int | NOT NULL | DEFAULT 1, CHECK (Quantity > 0) |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |

**Unique constraint**: (SpaceID, FacilityID)
**Delete policy**: Hard-delete (transient junction data)

### BookingRequest
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| BookingID | int | NOT NULL | PK, IDENTITY(1,1) |
| RequestedBy | int | NOT NULL | FK → User.UserID |
| SpaceID | int | NOT NULL | FK → Space.SpaceID |
| RequestedStartTime | datetime2 | NOT NULL | |
| RequestedEndTime | datetime2 | NOT NULL | CHECK (RequestedEndTime > RequestedStartTime) |
| Purpose | nvarchar(30) | NOT NULL | CHECK (Purpose IN ('Lecture','Examination','Seminar','Workshop','Meeting','StudentActivity','AdministrativeEvent')) |
| ExpectedParticipants | int | NOT NULL | CHECK (ExpectedParticipants > 0) |
| Status | nvarchar(20) | NOT NULL | DEFAULT 'Pending', CHECK (Status IN ('Pending','Approved','Rejected','Cancelled','CheckedIn','Completed','NoShow')) |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |

**Delete policy**: Hard-delete (transactional data; history preserved in BookingStatusHistory)

### BookingApproval
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| ApprovalID | int | NOT NULL | PK, IDENTITY(1,1) |
| BookingID | int | NOT NULL | FK → BookingRequest.BookingID, UNIQUE |
| ApprovedBy | int | NOT NULL | FK → User.UserID |
| DecisionTime | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| Decision | nvarchar(10) | NOT NULL | CHECK (Decision IN ('Approved','Rejected')) |
| DecisionNote | nvarchar(500) | NULL | |
| RejectionReason | nvarchar(500) | NULL | |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |

**Delete policy**: Hard-delete (transactional audit data)

### BookingSession
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| SessionID | int | NOT NULL | PK, IDENTITY(1,1) |
| BookingID | int | NOT NULL | FK → BookingRequest.BookingID, UNIQUE |
| CheckedInBy | int | NOT NULL | FK → User.UserID |
| ActualStartTime | datetime2 | NOT NULL | |
| InitialCondition | nvarchar(500) | NULL | |
| CheckedOutBy | int | NULL | FK → User.UserID |
| ActualEndTime | datetime2 | NULL | CHECK (ActualEndTime IS NULL OR ActualEndTime > ActualStartTime) |
| FinalCondition | nvarchar(500) | NULL | |
| UsageNotes | nvarchar(1000) | NULL | |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |

**Delete policy**: Hard-delete (transactional session data)

### BookingStatusHistory
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| StatusHistoryID | int | NOT NULL | PK, IDENTITY(1,1) |
| BookingID | int | NOT NULL | FK → BookingRequest.BookingID |
| FromStatus | nvarchar(20) | NULL | |
| ToStatus | nvarchar(20) | NOT NULL | CHECK (ToStatus IN ('Pending','Approved','Rejected','Cancelled','CheckedIn','Completed','NoShow')) |
| ChangedBy | int | NOT NULL | FK → User.UserID |
| ChangedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| Note | nvarchar(500) | NULL | |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |

**Delete policy**: Hard-delete (immutable audit log)

### MaintenanceRecord
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| MaintenanceID | int | NOT NULL | PK, IDENTITY(1,1) |
| SpaceID | int | NOT NULL | FK → Space.SpaceID |
| ReportedBy | int | NOT NULL | FK → User.UserID |
| AssignedTo | int | NULL | FK → User.UserID |
| ProblemDescription | nvarchar(1000) | NOT NULL | |
| StartTime | datetime2 | NOT NULL | |
| CompletionTime | datetime2 | NULL | |
| Status | nvarchar(20) | NOT NULL | DEFAULT 'Reported', CHECK (Status IN ('Reported','InProgress','Completed','Cancelled')) |
| ResultNote | nvarchar(1000) | NULL | |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| ModifiedAt | datetime2 | NULL | |

**Delete policy**: Hard-delete (transactional data; history in MaintenanceStatusHistory)

### MaintenanceStatusHistory
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| StatusHistoryID | int | NOT NULL | PK, IDENTITY(1,1) |
| MaintenanceID | int | NOT NULL | FK → MaintenanceRecord.MaintenanceID |
| FromStatus | nvarchar(20) | NULL | |
| ToStatus | nvarchar(20) | NOT NULL | CHECK (ToStatus IN ('Reported','InProgress','Completed','Cancelled')) |
| ChangedBy | int | NOT NULL | FK → User.UserID |
| ChangedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |
| Note | nvarchar(500) | NULL | |
| CreatedAt | datetime2 | NOT NULL | DEFAULT SYSUTCDATETIME() |

**Delete policy**: Hard-delete (immutable audit log)

## Mapping Notes from Conceptual Entities

| Conceptual Entity | Logical Relation | Notes |
|-------------------|-----------------|-------|
| User | User | Direct mapping |
| Space | Space | Direct mapping |
| Facility | Facility | Lookup table |
| SpaceFacility | SpaceFacility | Junction table resolving M:N |
| BookingRequest | BookingRequest | Direct mapping |
| BookingApproval | BookingApproval | 1:1 with BookingRequest via UNIQUE FK |
| BookingSession | BookingSession | 1:1 with BookingRequest via UNIQUE FK |
| BookingStatusHistory | BookingStatusHistory | History table for booking status |
| MaintenanceRecord | MaintenanceRecord | Direct mapping |
| MaintenanceStatusHistory | MaintenanceStatusHistory | History table for maintenance status |

## Audit Columns Applied

All transactional tables (BookingRequest, BookingApproval, BookingSession, BookingStatusHistory, MaintenanceRecord, MaintenanceStatusHistory) include `CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()` and `ModifiedAt DATETIME2 NULL`.

## Delete Policy Applied

| Policy | Tables |
|--------|--------|
| Soft-delete (IsActive, DeletedAt) | User, Space |
| Hard-delete | Facility, SpaceFacility, BookingRequest, BookingApproval, BookingSession, BookingStatusHistory, MaintenanceRecord, MaintenanceStatusHistory |
