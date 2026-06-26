# Logical Database Design - Group 04

## Relational Schema

- **Users** (**UserID**, Name, Email, Phone, Role, Department, Status)
- **Spaces** (**SpaceCode**, Name, Type, Building, Floor, RoomNumber, Capacity, Status, UsagePolicy)
- **FacilityTypes** (**TypeID**, Name)
- **SpaceFacilities** (**SpaceCode**, **TypeID**) - *FK: SpaceCode references Spaces(SpaceCode), TypeID references FacilityTypes(TypeID)*
- **Bookings** (**BookingID**, SpaceCode, RequesterID, StartTime, EndTime, Purpose, ExpectedParticipants, Status, DecisionByUserID, DecisionTime, DecisionNote, RejectionReason, ActualStartTime, ActualEndTime, CheckerInUserID, InitialCondition, FinalCondition, UsageNotes)
  - *FK: SpaceCode references Spaces(SpaceCode)*
  - *FK: RequesterID references Users(UserID)*
  - *FK: DecisionByUserID references Users(UserID)*
  - *FK: CheckerInUserID references Users(UserID)*
- **Maintenance** (**MaintenanceID**, SpaceCode, ReporterUserID, AssignedStaffID, Description, StartTime, CompletionTime, Status, ResultNote)
  - *FK: SpaceCode references Spaces(SpaceCode)*
  - *FK: ReporterUserID references Users(UserID)*
  - *FK: AssignedStaffID references Users(UserID)*
