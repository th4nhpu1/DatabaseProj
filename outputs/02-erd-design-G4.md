# Conceptual Design / ERD — Campus Space Management System

## Mermaid ER Diagram

```mermaid
erDiagram
    User ||--o{ BookingRequest : requests
    User ||--o{ BookingApproval : approves
    User ||--o{ BookingSession : "checks in/out"
    User ||--o{ MaintenanceRecord : "reports / is assigned"
    BookingRequest ||--|| BookingApproval : "has approval"
    BookingRequest ||--|| BookingSession : "has session"
    BookingRequest ||--o{ BookingStatusHistory : "has history"
    Space ||--o{ BookingRequest : "is booked in"
    Space ||--o{ SpaceFacility : "contains"
    Space ||--o{ MaintenanceRecord : "undergoes"
    Facility ||--o{ SpaceFacility : "appears in"
    MaintenanceRecord ||--o{ MaintenanceStatusHistory : "has history"

    User {
        int UserID PK
        nvarchar FullName
        nvarchar Email UK
        nvarchar Phone
        nvarchar Role
        nvarchar Department
        nvarchar AccountStatus
    }

    Space {
        int SpaceID PK
        nvarchar SpaceCode UK
        nvarchar SpaceName
        nvarchar SpaceType
        nvarchar Building
        int Floor
        nvarchar RoomNumber
        int Capacity
        nvarchar Status
        nvarchar UsagePolicy
    }

    Facility {
        int FacilityID PK
        nvarchar FacilityName UK
    }

    SpaceFacility {
        int SpaceFacilityID PK
        int SpaceID FK
        int FacilityID FK
        int Quantity
    }

    BookingRequest {
        int BookingID PK
        int RequestedBy FK
        int SpaceID FK
        datetime2 RequestedStartTime
        datetime2 RequestedEndTime
        nvarchar Purpose
        int ExpectedParticipants
        nvarchar Status
    }

    BookingApproval {
        int ApprovalID PK
        int BookingID FK UK
        int ApprovedBy FK
        datetime2 DecisionTime
        nvarchar Decision
        nvarchar DecisionNote
        nvarchar RejectionReason
    }

    BookingSession {
        int SessionID PK
        int BookingID FK UK
        int CheckedInBy FK
        datetime2 ActualStartTime
        nvarchar InitialCondition
        int CheckedOutBy FK
        datetime2 ActualEndTime
        nvarchar FinalCondition
        nvarchar UsageNotes
    }

    BookingStatusHistory {
        int StatusHistoryID PK
        int BookingID FK
        nvarchar FromStatus
        nvarchar ToStatus
        int ChangedBy FK
        datetime2 ChangedAt
        nvarchar Note
    }

    MaintenanceRecord {
        int MaintenanceID PK
        int SpaceID FK
        int ReportedBy FK
        int AssignedTo FK
        nvarchar ProblemDescription
        datetime2 StartTime
        datetime2 CompletionTime
        nvarchar Status
        nvarchar ResultNote
    }

    MaintenanceStatusHistory {
        int StatusHistoryID PK
        int MaintenanceID FK
        nvarchar FromStatus
        nvarchar ToStatus
        int ChangedBy FK
        datetime2 ChangedAt
        nvarchar Note
    }
```

## Entity Details

### User
- **Identifier**: UserID (surrogate)
- **Key attributes**: FullName, Email (unique), Phone, Role, Department, AccountStatus
- **Optional**: none

### Space
- **Identifier**: SpaceID (surrogate); SpaceCode is an alternate key
- **Key attributes**: SpaceName, SpaceType, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy
- **Optional**: UsagePolicy

### Facility (lookup)
- **Identifier**: FacilityID (surrogate); FacilityName is an alternate key
- **Purpose**: Normalized list of facility types

### SpaceFacility (junction)
- **Purpose**: Links facilities to spaces with quantity
- **Cardinality**: Many-to-many between Space and Facility resolved to one-to-many from each side

### BookingRequest
- **Identifier**: BookingID (surrogate)
- **Status lifecycle**: Pending → Approved/Rejected/Cancelled → CheckedIn → Completed/NoShow
- **History**: Tracked via BookingStatusHistory (dedicated history table, not temporal table)

### BookingApproval
- **Identifier**: ApprovalID (surrogate)
- **One-to-one** with BookingRequest (BookingID is UNIQUE)

### BookingSession
- **Identifier**: SessionID (surrogate)
- **One-to-one** with BookingRequest (BookingID is UNIQUE)
- CheckedOutBy, ActualEndTime, FinalCondition, UsageNotes are nullable until check-out occurs

### BookingStatusHistory
- **Purpose**: Immutable log of every status transition for a booking
- **FromStatus** is NULL for the initial Pending entry

### MaintenanceRecord
- **Identifier**: MaintenanceID (surrogate)
- **Status lifecycle**: Reported → InProgress → Completed/Cancelled
- **Optional**: AssignedTo, CompletionTime, ResultNote are nullable until assigned/completed

### MaintenanceStatusHistory
- **Purpose**: Immutable log of every status transition for a maintenance record

## History Tracking Approach

**Dedicated history tables** (`BookingStatusHistory`, `MaintenanceStatusHistory`) are used rather than SQL Server temporal tables. This provides explicit control over what is recorded, allows custom notes per transition, and keeps the main tables lightweight.

## Conflict and Constraint Representation

- **Overlapping bookings**: Enforced via a database trigger that checks for time overlap on Approved/CheckedIn bookings for the same space (cannot be done with a simple unique constraint in SQL Server).
- **Maintenance blocks**: Enforced via a database trigger that checks if the target space has active (non-Completed/non-Cancelled) maintenance before allowing a booking to be Approved.
- **Status transitions**: Enforced via CHECK constraints on the Status column in BookingRequest and MaintenanceRecord, and the history tables record every transition immutably.

## Assumptions Affecting Conceptual Design

- All bookings require approval (no concept of "auto-approved" or "no-approval-needed" bookings).
- A booking moves directly from Approved to CheckedIn (no intermediate states).
- No-show is determined by absence of check-in; the system does not auto-transition — a staff member marks it.
- Facilities are shared across spaces via a junction table, not stored as a JSON list.
