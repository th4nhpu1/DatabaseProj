# Business Requirement Analysis - Group 04

## Actors & Roles
- **Student**: Requests spaces for projects/activities.
- **Lecturer/Teaching Assistant**: Requests spaces for teaching/seminars.
- **Facility Staff**: Manages booking approvals, check-ins, check-outs, and maintenance.
- **Department Administrator/Facility Manager**: Oversees operations and reports.
- **System**: Enforces business rules (no conflicts, status checks).

## Entities & Attributes
- **User**: UserID (PK), Name, Email, Phone, Role, Department, AccountStatus.
- **Space**: SpaceCode (PK), Name, Type, Building, Floor, RoomNumber, Capacity, CurrentStatus, UsagePolicy.
- **FacilityType**: TypeID (PK), Name (e.g., Projector, Whiteboard).
- **SpaceFacility**: SpaceCode (FK), TypeID (FK).
- **Booking**: BookingID (PK), SpaceCode (FK), RequesterID (FK), StartTime, EndTime, Purpose, ExpectedParticipants, Status, DecisionByUserID (FK), DecisionTime, DecisionNote, RejectionReason, ActualStartTime, ActualEndTime, CheckerInUserID (FK), InitialCondition, FinalCondition, UsageNotes.
- **Maintenance**: MaintenanceID (PK), SpaceCode (FK), ReporterUserID (FK), AssignedStaffID (FK), Description, StartTime, CompletionTime, Status, ResultNote.

## Relationships
- **User** requests **Booking**.
- **Booking** occupies **Space**.
- **Space** contains **SpaceFacility** (linked to **FacilityType**).
- **Space** has **Maintenance** records.
- **Booking** approved/checked in by **User** (Staff).
- **Maintenance** reported by **User**.
- **Maintenance** assigned to **User** (Staff).
