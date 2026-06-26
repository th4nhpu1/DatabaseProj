# Design Validation - Group 04

## Evaluation
The proposed relational schema effectively maps all business requirements identified in the analysis phase.

### Strengths
- **Normalization**: Tables are normalized (e.g., separating `FacilityTypes` from `Spaces` avoids redundancy).
- **Completeness**: All aspects, including maintenance and booking life cycles, are captured.
- **Traceability**: All entities and relationships directly map back to requirements.

### Considerations (Implementation)
- **Constraint Enforcement**: Database constraints (e.g., CHECK constraints for Booking Status) and triggers will be necessary to prevent overlapping bookings and ensure referential integrity for complex rules.
- **Query Performance**: Indexes on `SpaceCode`, `StartTime`, `EndTime`, and `Status` columns will be crucial for performance given the requirement to manage historical data.
- **Security**: Access control should be implemented at the application level to restrict actions based on user roles.
