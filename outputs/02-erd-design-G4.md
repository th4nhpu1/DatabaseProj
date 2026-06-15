# Conceptual Design (ERD) — Campus Space Management System

## Mermaid ER Diagram

```mermaid
erDiagram
    User ||--o{ Booking : submits
    User ||--o{ Maintenance : reports
    User ||--o{ Maintenance : assigned_to
    Space ||--o{ Booking : has
    Space ||--o{ SpaceFacility : equipped_with
    Space ||--o{ Maintenance : requires
    Facility ||--o{ SpaceFacility : installed_in
    Booking ||--o| BookingApproval : approved_by
    Booking ||--o| BookingSession : checked_in

    User {
        int user_id PK
        string full_name
        string email UK
        string phone
        string role
        string department
        string account_status
    }

    Space {
        string space_code PK
        string space_name
        string space_type
        string building
        string floor
        string room_number
        int capacity
        string status
        string usage_policy
    }

    Facility {
        int facility_id PK
        string facility_name UK
    }

    SpaceFacility {
        string space_code PK, FK
        int facility_id PK, FK
    }

    Booking {
        int booking_id PK
        int user_id FK
        string space_code FK
        datetime requested_start
        datetime requested_end
        string purpose
        int expected_participants
        string booking_type
        string status
        datetime created_at
    }

    BookingApproval {
        int approval_id PK
        int booking_id FK UK
        int staff_id FK
        string decision
        datetime decision_time
        string decision_note
    }

    BookingSession {
        int session_id PK
        int booking_id FK UK
        datetime actual_start
        int checked_in_by FK
        string initial_condition
        datetime actual_end
        string final_condition
        string usage_notes
    }

    Maintenance {
        int maintenance_id PK
        string space_code FK
        int reporter_id FK
        int assigned_to FK
        string problem_description
        datetime start_time
        datetime completion_time
        string status
        string result_note
    }
```

## Entity Descriptions

### User
Central entity for all system users. Account status controls whether the user can make bookings.

### Space
Every bookable room or area. Status determines availability for booking.

### Facility
Lookup of equipment/furnishings that may exist in spaces.

### SpaceFacility
Associative entity linking spaces to their available facilities (M:N).

### Booking
Core transaction entity. Status drives the booking lifecycle.

### BookingApproval
Records the approval or rejection decision for a booking. Optional — a booking may not yet have been reviewed.

### BookingSession
Captures check-in and check-out details for a booking that reached the usage stage.

### Maintenance
Tracks all repair and upkeep activities for spaces.

## Relationships and Cardinalities

| Left Entity | Relationship | Right Entity | Cardinality | Participation |
|-------------|-------------|--------------|-------------|---------------|
| User | submits | Booking | 1:N | Mandatory (User) / Optional (Booking) |
| Space | has | Booking | 1:N | Mandatory (Space) / Optional (Booking) |
| Space | equipped_with | SpaceFacility | 1:N | Mandatory (Space) / Optional (SpaceFacility) |
| Facility | installed_in | SpaceFacility | 1:N | Mandatory (Facility) / Optional (SpaceFacility) |
| Space | requires | Maintenance | 1:N | Mandatory (Space) / Optional (Maintenance) |
| User | reports | Maintenance | 1:N | Optional (User) / Optional (Maintenance) |
| User | assigned_to | Maintenance | 1:N | Optional (User) / Optional (Maintenance) |
| Booking | approved_by | BookingApproval | 1:1 | Mandatory (Booking) / Optional (BookingApproval) |
| Booking | checked_in | BookingSession | 1:1 | Mandatory (Booking) / Optional (BookingSession) |

## Notes

- Booking.status and BookingApproval.decision are intentionally separate to support pending → rejected flows without deleting records.
- BookingSession stores both check-in and check-out data in one table to keep the lifecycle self-contained.
- User has two relationships to Maintenance (reporter and assignee) — both are optional since the system may record maintenance without linking to a specific user.
