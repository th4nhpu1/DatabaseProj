# Logical Database Design — Campus Space Management System

## Relational Schema

### User
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| user_id | INT | NOT NULL | PRIMARY KEY, IDENTITY(1,1) |
| full_name | NVARCHAR(100) | NOT NULL | |
| email | NVARCHAR(255) | NOT NULL | UNIQUE |
| phone | NVARCHAR(20) | NULL | |
| role | NVARCHAR(30) | NOT NULL | CHECK (role IN ('student','lecturer','ta','facility_staff','dept_admin','facility_manager')) |
| department | NVARCHAR(100) | NOT NULL | |
| account_status | NVARCHAR(20) | NOT NULL | DEFAULT 'active', CHECK (account_status IN ('active','inactive','suspended')) |

### Space
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| space_code | NVARCHAR(20) | NOT NULL | PRIMARY KEY |
| space_name | NVARCHAR(100) | NOT NULL | |
| space_type | NVARCHAR(30) | NOT NULL | CHECK (space_type IN ('auditorium','classroom','computer_lab','project_lab','meeting_room','student_workspace')) |
| building | NVARCHAR(100) | NOT NULL | |
| floor | NVARCHAR(10) | NOT NULL | |
| room_number | NVARCHAR(20) | NOT NULL | |
| capacity | INT | NOT NULL | CHECK (capacity > 0) |
| status | NVARCHAR(30) | NOT NULL | DEFAULT 'available', CHECK (status IN ('available','in_use','under_maintenance','temporarily_closed','retired')) |
| usage_policy | NVARCHAR(MAX) | NULL | |

### Facility
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| facility_id | INT | NOT NULL | PRIMARY KEY, IDENTITY(1,1) |
| facility_name | NVARCHAR(100) | NOT NULL | UNIQUE |

### SpaceFacility
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| space_code | NVARCHAR(20) | NOT NULL | PRIMARY KEY (composite), FK → Space(space_code) |
| facility_id | INT | NOT NULL | PRIMARY KEY (composite), FK → Facility(facility_id) |

### Booking
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| booking_id | INT | NOT NULL | PRIMARY KEY, IDENTITY(1,1) |
| user_id | INT | NOT NULL | FK → User(user_id) |
| space_code | NVARCHAR(20) | NOT NULL | FK → Space(space_code) |
| requested_start | DATETIME2 | NOT NULL | |
| requested_end | DATETIME2 | NOT NULL | CHECK (requested_end > requested_start) |
| purpose | NVARCHAR(MAX) | NOT NULL | |
| expected_participants | INT | NOT NULL | CHECK (expected_participants > 0) |
| booking_type | NVARCHAR(30) | NOT NULL | CHECK (booking_type IN ('lecture','examination','seminar','workshop','meeting','student_activity','admin_event')) |
| status | NVARCHAR(20) | NOT NULL | DEFAULT 'pending', CHECK (status IN ('pending','approved','rejected','cancelled','checked_in','completed','no_show')) |
| created_at | DATETIME2 | NOT NULL | DEFAULT GETDATE() |

### BookingApproval
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| approval_id | INT | NOT NULL | PRIMARY KEY, IDENTITY(1,1) |
| booking_id | INT | NOT NULL | UNIQUE, FK → Booking(booking_id) |
| staff_id | INT | NOT NULL | FK → User(user_id) |
| decision | NVARCHAR(20) | NOT NULL | CHECK (decision IN ('approved','rejected')) |
| decision_time | DATETIME2 | NOT NULL | DEFAULT GETDATE() |
| decision_note | NVARCHAR(MAX) | NULL | |

### BookingSession
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| session_id | INT | NOT NULL | PRIMARY KEY, IDENTITY(1,1) |
| booking_id | INT | NOT NULL | UNIQUE, FK → Booking(booking_id) |
| actual_start | DATETIME2 | NOT NULL | |
| checked_in_by | INT | NOT NULL | FK → User(user_id) |
| initial_condition | NVARCHAR(MAX) | NULL | |
| actual_end | DATETIME2 | NULL | |
| final_condition | NVARCHAR(MAX) | NULL | |
| usage_notes | NVARCHAR(MAX) | NULL | |

### Maintenance
| Column | Type | Nullable | Constraints |
|--------|------|----------|-------------|
| maintenance_id | INT | NOT NULL | PRIMARY KEY, IDENTITY(1,1) |
| space_code | NVARCHAR(20) | NOT NULL | FK → Space(space_code) |
| reporter_id | INT | NULL | FK → User(user_id) |
| assigned_to | INT | NULL | FK → User(user_id) |
| problem_description | NVARCHAR(MAX) | NOT NULL | |
| start_time | DATETIME2 | NOT NULL | |
| completion_time | DATETIME2 | NULL | |
| status | NVARCHAR(20) | NOT NULL | DEFAULT 'reported', CHECK (status IN ('reported','assigned','in_progress','completed','cancelled')) |
| result_note | NVARCHAR(MAX) | NULL | |

## Mapping Notes

| Conceptual Entity | Relation | Notes |
|-------------------|----------|-------|
| User | User | All roles consolidated into single table with role discriminator |
| Space | Space | Status values expanded for maintenance/closure tracking |
| Facility | Facility | Simple lookup table |
| SpaceFacility | SpaceFacility | Composite PK from space_code and facility_id |
| Booking | Booking | Status drives lifecycle; no separate status lookup table to keep schema flat |
| BookingApproval | BookingApproval | 1:1 with Booking; UNIQUE constraint on booking_id enforces this |
| BookingSession | BookingSession | Combines check-in and check-out; actual_end nullable until completed |
| Maintenance | Maintenance | Two FK references to User (reporter and assignee) |

## Constraint Rationale

- Overlapping approved bookings are prevented by a table-level CHECK or application-level validation (SQL Server does not support regex-based interval overlap checks natively; a trigger or application logic enforces this).
- CHECK constraints enforce domain values for all status and type columns to prevent invalid state transitions.
- UNIQUE on BookingApproval.booking_id and BookingSession.booking_id ensures 1:1 relationship cardinality.
- FK cascading is set to NO ACTION to prevent accidental deletion of historical records.
