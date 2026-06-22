# Logical Design — Group 04

## Table: User

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| userId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| fullName | NVARCHAR | 150 | NOT NULL | — |
| email | NVARCHAR | 255 | NOT NULL | UNIQUE |
| phone | NVARCHAR | 20 | YES | — |
| role | NVARCHAR | 50 | NOT NULL | CHECK (role IN (...)) |
| department | NVARCHAR | 100 | YES | — |
| accountStatus | NVARCHAR | 20 | NOT NULL | DEFAULT 'active' |

## Table: Space

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| spaceCode | NVARCHAR | 20 | NOT NULL | PK |
| spaceName | NVARCHAR | 200 | NOT NULL | — |
| spaceType | NVARCHAR | 50 | NOT NULL | CHECK (spaceType IN (...)) |
| building | NVARCHAR | 100 | NOT NULL | — |
| floor | INT | — | NOT NULL | — |
| roomNumber | NVARCHAR | 20 | NOT NULL | — |
| capacity | INT | — | NOT NULL | CHECK (capacity > 0) |
| currentStatus | NVARCHAR | 30 | NOT NULL | DEFAULT 'available' |
| usagePolicy | NVARCHAR | MAX | YES | — |

## Table: Facility

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| facilityId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| facilityName | NVARCHAR | 100 | NOT NULL | UNIQUE |
| description | NVARCHAR | 500 | YES | — |

## Table: SpaceFacility

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| spaceCode | NVARCHAR | 20 | NOT NULL | PK (composite), FK → Space |
| facilityId | INT | — | NOT NULL | PK (composite), FK → Facility |
| quantity | INT | — | NOT NULL | DEFAULT 1, CHECK (> 0) |

## Table: Booking

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| userId | INT | — | NOT NULL | FK → User |
| spaceCode | NVARCHAR | 20 | NOT NULL | FK → Space |
| requestedStartTime | DATETIME2(2) | — | NOT NULL | — |
| requestedEndTime | DATETIME2(2) | — | NOT NULL | CHECK (end > start) |
| purpose | NVARCHAR | 500 | YES | — |
| expectedParticipants | INT | — | NOT NULL | CHECK (> 0) |
| bookingType | NVARCHAR | 30 | NOT NULL | CHECK (IN ...) |
| status | NVARCHAR | 20 | NOT NULL | DEFAULT 'pending' |
| submittedAt | DATETIME2(2) | — | NOT NULL | DEFAULT GETUTCDATE() |

## Table: BookingApproval

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, FK → Booking (CASCADE) |
| decisionBy | INT | — | NOT NULL | FK → User |
| decisionTime | DATETIME2(2) | — | NOT NULL | — |
| decisionNote | NVARCHAR | 500 | YES | — |
| rejectionReason | NVARCHAR | 500 | YES | — |

## Table: CheckIn

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, FK → Booking (CASCADE) |
| checkedInBy | INT | — | NOT NULL | FK → User |
| actualStartTime | DATETIME2(2) | — | NOT NULL | — |
| initialCondition | NVARCHAR | 500 | YES | — |

## Table: CheckOut

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, FK → Booking (CASCADE) |
| actualEndTime | DATETIME2(2) | — | NOT NULL | — |
| finalCondition | NVARCHAR | 500 | YES | — |
| usageNotes | NVARCHAR | MAX | YES | — |

## Table: MaintenanceRecord

| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| recordId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| spaceCode | NVARCHAR | 20 | NOT NULL | FK → Space |
| reportedBy | INT | — | NOT NULL | FK → User |
| assignedTo | INT | — | YES | FK → User (SET NULL) |
| problemDescription | NVARCHAR | 1000 | NOT NULL | — |
| startTime | DATETIME2(2) | — | NOT NULL | — |
| completionTime | DATETIME2(2) | — | YES | — |
| status | NVARCHAR | 20 | NOT NULL | DEFAULT 'reported' |
| resultNote | NVARCHAR | 1000 | YES | — |

## Table Summary

| Table | Description | Est. Rows | Growth |
|---|---|---|---|
| User | System users | 500 | Low |
| Space | Bookable spaces | 50 | Very low |
| Facility | Equipment types | 20 | Very low |
| SpaceFacility | Space-facility assignment | 200 | Low |
| Booking | Booking requests | 10,000/year | Medium |
| BookingApproval | Approvals/rejections | 8,000/year | Medium |
| CheckIn | Check-in records | 6,000/year | Medium |
| CheckOut | Check-out records | 5,500/year | Medium |
| MaintenanceRecord | Maintenance issues | 200/year | Low |

## Referential Integrity

| FK Table | FK Column(s) | Parent Table | On Update | On Delete |
|---|---|---|---|---|
| Booking | userId | User | NO ACTION | NO ACTION |
| Booking | spaceCode | Space | NO ACTION | NO ACTION |
| BookingApproval | bookingId | Booking | CASCADE | CASCADE |
| BookingApproval | decisionBy | User | NO ACTION | NO ACTION |
| CheckIn | bookingId | Booking | CASCADE | CASCADE |
| CheckIn | checkedInBy | User | NO ACTION | NO ACTION |
| CheckOut | bookingId | Booking | CASCADE | CASCADE |
| SpaceFacility | spaceCode | Space | CASCADE | CASCADE |
| SpaceFacility | facilityId | Facility | CASCADE | CASCADE |
| MaintenanceRecord | spaceCode | Space | CASCADE | NO ACTION |
| MaintenanceRecord | reportedBy | User | NO ACTION | NO ACTION |
| MaintenanceRecord | assignedTo | User | NO ACTION | SET NULL |

## Assumptions

1. BookingApproval, CheckIn, and CheckOut use bookingId as PK (1:0..1 relationships).
2. Cross-table validation (e.g., CheckOut time > CheckIn time) is enforced at the application layer.
3. rejectionReason is application-enforced to be non-null when status = 'rejected'.
4. All IDENTITY seeds start at 1 and increment by 1.
5. DATETIME2(2) balances precision (~10 ms) with storage efficiency.
