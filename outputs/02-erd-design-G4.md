# Conceptual Design / ERD — Campus Space Management System

## Mermaid ER Diagram

```mermaid
erDiagram
    User ||--o{ BookingRequest : "submits"
    User ||--o{ BookingApproval : "decides"
    User ||--o{ CheckIn : "checks in"
    User ||--o{ CheckOut : "checks out"
    User ||--o{ MaintenanceRecord : "reports"
    User ||--o{ MaintenanceRecord : "assigned to"
    User ||--o{ BookingStatusHistory : "triggers status change"
    User ||--o{ MaintenanceStatusHistory : "triggers maintenance status change"

    Space ||--o{ BookingRequest : "is booked in"
    Space ||--o{ SpaceFacility : "contains"
    Space ||--o{ MaintenanceRecord : "undergoes"

    Facility ||--o{ SpaceFacility : "installed in"

    BookingRequest ||--o| BookingApproval : "may require"
    BookingRequest ||--o| CheckIn : "has check-in"
    BookingRequest ||--o| CheckOut : "has check-out"
    BookingRequest ||--o{ BookingStatusHistory : "records history"

    MaintenanceRecord ||--o{ MaintenanceStatusHistory : "records maintenance history"

    BookingRequest {
        int BookingID PK
        int RequestedByUserID FK
        int SpaceID FK
        datetime RequestedStartTime
        datetime RequestedEndTime
        string Purpose
        string PurposeType
        int ExpectedParticipants
        string Status
        datetime CreatedAt
        datetime ModifiedAt
    }

    User {
        int UserID PK
        string FullName
        string Email
        string PhoneNumber
        string Role
        string Department
        string AccountStatus
        bool IsActive
        datetime CreatedAt
        datetime ModifiedAt
    }

    Space {
        int SpaceID PK
        string SpaceCode UK
        string SpaceName
        string SpaceType
        string Building
        string Floor
        string RoomNumber
        int Capacity
        string Status
        string UsagePolicy
        bool IsActive
        datetime CreatedAt
        datetime ModifiedAt
    }

    Facility {
        int FacilityID PK
        string FacilityName
        string Description
    }

    SpaceFacility {
        int SpaceID FK
        int FacilityID FK
    }

    BookingApproval {
        int ApprovalID PK
        int BookingID FK
        int ApprovedByUserID FK
        datetime DecisionTime
        string Decision
        string DecisionNote
        string RejectionReason
    }

    CheckIn {
        int BookingID PK FK
        int CheckedInByUserID FK
        datetime ActualStartTime
        string InitialCondition
    }

    CheckOut {
        int BookingID PK FK
        int CheckedOutByUserID FK
        datetime ActualEndTime
        string FinalCondition
        string UsageNotes
    }

    MaintenanceRecord {
        int MaintenanceID PK
        int SpaceID FK
        int ReportedByUserID FK
        int AssignedToUserID FK
        string ProblemDescription
        string ProblemType
        datetime StartTime
        datetime CompletionTime
        string Status
        string ResultNote
        datetime CreatedAt
        datetime ModifiedAt
    }

    BookingStatusHistory {
        int HistoryID PK
        int BookingID FK
        string PreviousStatus
        string NewStatus
        int ChangedByUserID FK
        datetime ChangedAt
        string Note
    }

    MaintenanceStatusHistory {
        int HistoryID PK
        int MaintenanceRecordID FK
        string PreviousStatus
        string NewStatus
        int ChangedByUserID FK
        datetime ChangedAt
        string Note
    }
```

## Main Entities with Identifiers and Key Attributes

| Entity | Identifier | Key Attributes |
|--------|-----------|---------------|
| User | UserID (PK, surrogate INT IDENTITY) | Email (UK), FullName, Role, Department, AccountStatus |
| Space | SpaceID (PK, surrogate INT IDENTITY) | SpaceCode (UK), SpaceName, SpaceType, Building, Capacity |
| Facility | FacilityID (PK, surrogate INT IDENTITY) | FacilityName (UK) |
| SpaceFacility | (SpaceID, FacilityID) composite PK | — |
| BookingRequest | BookingID (PK, surrogate INT IDENTITY) | RequestedStartTime, RequestedEndTime, Status |
| BookingApproval | ApprovalID (PK, surrogate INT IDENTITY) | Decision (Approved/Rejected), DecisionTime |
| CheckIn | BookingID (PK, FK) | ActualStartTime, InitialCondition |
| CheckOut | BookingID (PK, FK) | ActualEndTime, FinalCondition |
| MaintenanceRecord | MaintenanceID (PK, surrogate INT IDENTITY) | ProblemDescription, ProblemType, Status |
| BookingStatusHistory | HistoryID (PK, surrogate INT IDENTITY) | PreviousStatus, NewStatus, ChangedAt |
| MaintenanceStatusHistory | HistoryID (PK, surrogate INT IDENTITY) | PreviousStatus, NewStatus, ChangedAt |

## Relationship Names, Cardinalities, and Participation Constraints

| Verb | From | To | Cardinality | Participation |
|------|------|----|-------------|---------------|
| submits | User | BookingRequest | 1:N | Mandatory (User must exist for a booking) |
| decides | User | BookingApproval | 1:N | Optional (some bookings don't need approval) |
| checks in | User | CheckIn | 1:N | Optional (only staff perform check-ins) |
| checks out | User | CheckOut | 1:N | Optional |
| reports | User | MaintenanceRecord | 1:N | Optional |
| assigned to | User | MaintenanceRecord | 1:N | Optional |
| is booked in | Space | BookingRequest | 1:N | Mandatory |
| contains | Space | SpaceFacility | 1:N | Optional |
| undergoes | Space | MaintenanceRecord | 1:N | Optional |
| installed in | Facility | SpaceFacility | 1:N | Optional |
| may require | BookingRequest | BookingApproval | 1:0..1 | Optional (conditional approval) |
| has check-in | BookingRequest | CheckIn | 1:0..1 | Optional |
| has check-out | BookingRequest | CheckOut | 1:0..1 | Optional |
| records history | BookingRequest | BookingStatusHistory | 1:N | Mandatory |
| records history | MaintenanceRecord | MaintenanceStatusHistory | 1:N | Mandatory |

## Notes on Optionality, Historical Tracking, and Status-Driven Behavior

- **History Tracking**: Dedicated `BookingStatusHistory` and `MaintenanceStatusHistory` tables track all status transitions. This is not a temporal table approach — it's an explicit history table pattern, per project conventions. Each record captures `PreviousStatus`, `NewStatus`, `ChangedByUserID`, and `ChangedAt`.
- **Conditional Approval**: The `BookingApproval` relationship from `BookingRequest` is 0-or-1 (optional). This supports scenarios where certain bookings (e.g., lecturers in their designated rooms during teaching hours) skip manual approval.
- **Overlapping Pending Requests**: Multiple overlapping `Pending` requests for the same space are structurally allowed (no unique constraint on SpaceID + time range for pending status). Conflict enforcement happens only when a request transitions to `Approved`. The application layer or a scheduled job checks for conflicts before allowing the approval transition.
- **Maintenance Blocks**: The relationship between `Space` and `MaintenanceRecord` creates a structural basis for checking: before approving a booking, the system verifies no active maintenance overlaps the requested time. This is enforced via application logic and can be supplemented with a table-valued function.
- **Soft Delete**: `User.IsActive` and `Space.IsActive` implement soft-delete. Transactional data (BookingRequest, etc.) uses hard-delete only for genuinely transient data.

## Structural Logic for Overlapping Pending Requests

1. A new booking request is inserted with status `Pending`.
2. No conflict check is performed at insert time for the `Pending` state.
3. When a request is being approved (either manually or via auto-approval), the system checks:
   - No other **approved** booking overlaps the same space and time range.
   - No active maintenance record overlaps the same space and time range.
   - The space is not closed/retired.
4. If all checks pass, the request transitions to `Approved` and a history record is inserted.
5. Other `Pending` requests for the same time slot remain pending; only one can eventually be approved.

## Assumptions Affecting Conceptual Design

- History tables are used instead of SQL Server temporal tables (per project conventions).
- Auto-approval logic is driven by role + space type + time, but the exact rules are deferred to application configuration (Q1 from Step 1).
- Soft-delete policy: Space and User use IsActive flag; transactional tables use hard-delete.
