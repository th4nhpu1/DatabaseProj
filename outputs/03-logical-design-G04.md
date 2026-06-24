# Logical Design — Group 04

## Table Mappings

### User
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| userId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| fullName | NVARCHAR | 150 | NOT NULL | — |
| email | NVARCHAR | 255 | NOT NULL | UNIQUE |
| phone | NVARCHAR | 20 | YES | — |
| role | NVARCHAR | 50 | NOT NULL | CHECK (role IN (...)) |
| department | NVARCHAR | 100 | YES | — |
| accountStatus | NVARCHAR | 20 | NOT NULL | DEFAULT 'active' |

### Space
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| spaceCode | NVARCHAR | 20 | NOT NULL | PK |
| spaceName | NVARCHAR | 200 | NOT NULL | — |
| spaceType | NVARCHAR | 50 | NOT NULL | CHECK (IN ...) |
| building | NVARCHAR | 100 | NOT NULL | — |
| floor | INT | — | NOT NULL | — |
| roomNumber | NVARCHAR | 20 | NOT NULL | — |
| capacity | INT | — | NOT NULL | CHECK (> 0) |
| currentStatus | NVARCHAR | 30 | NOT NULL | DEFAULT 'available' |
| usagePolicy | NVARCHAR | MAX | YES | — |

### Facility
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| facilityId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| facilityName | NVARCHAR | 100 | NOT NULL | UNIQUE |
| description | NVARCHAR | 500 | YES | — |

### SpaceFacility
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| spaceCode | NVARCHAR | 20 | NOT NULL | PK (composite), FK → Space |
| facilityId | INT | — | NOT NULL | PK (composite), FK → Facility |
| quantity | INT | — | NOT NULL | DEFAULT 1, CHECK (> 0) |

### Booking
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| userId | INT | — | NOT NULL | FK → User(userId) |
| spaceCode | NVARCHAR | 20 | NOT NULL | FK → Space(spaceCode) |
| requestedStartTime | DATETIME2(2) | — | NOT NULL | — |
| requestedEndTime | DATETIME2(2) | — | NOT NULL | CHECK (end > start) |
| purpose | NVARCHAR | 500 | YES | — |
| expectedParticipants | INT | — | NOT NULL | CHECK (> 0) |
| bookingType | NVARCHAR | 30 | NOT NULL | CHECK (IN ...) |
| status | NVARCHAR | 20 | NOT NULL | DEFAULT 'pending' |
| submittedAt | DATETIME2(2) | — | NOT NULL | DEFAULT SYSUTCDATETIME() |

### BookingApproval
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, FK → Booking |
| decisionBy | INT | — | NOT NULL | FK → User(userId) |
| decisionTime | DATETIME2(2) | — | NOT NULL | — |
| decisionNote | NVARCHAR | 500 | YES | — |
| rejectionReason | NVARCHAR | 500 | YES | — |

### CheckIn
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, FK → Booking |
| checkedInBy | INT | — | NOT NULL | FK → User(userId) |
| actualStartTime | DATETIME2(2) | — | NOT NULL | — |
| initialCondition | NVARCHAR | 500 | YES | — |

### CheckOut
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| bookingId | INT | — | NOT NULL | PK, FK → Booking |
| actualEndTime | DATETIME2(2) | — | NOT NULL | — |
| finalCondition | NVARCHAR | 500 | YES | — |
| usageNotes | NVARCHAR | MAX | YES | — |

### MaintenanceRecord
| Column | Type | Length | Nullable | Constraint |
|---|---|---|---|---|
| recordId | INT | — | NOT NULL | PK, IDENTITY(1,1) |
| spaceCode | NVARCHAR | 20 | NOT NULL | FK → Space |
| reportedBy | INT | — | NOT NULL | FK → User |
| assignedTo | INT | — | YES | FK → User, SET NULL |
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
| SpaceFacility | Space-facility assignments | 200 | Low |
| Booking | Booking requests | 10,000/yr | Medium |
| BookingApproval | Approval/rejection records | 8,000/yr | Medium |
| CheckIn | Check-in records | 6,000/yr | Medium |
| CheckOut | Check-out records | 5,500/yr | Medium |
| MaintenanceRecord | Maintenance issues | 200/yr | Low |

## Referential Integrity

| FK Table | FK Column(s) | Parent | ON UPDATE | ON DELETE |
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
