## 1. Architectural Standardization and Database Conventions
- This version introduces a global, upfront configuration baseline that was completely absent in version 1. This ensures architectural consistency across all downstream deliverables:
- Identifier Strategy: Explicitly standardizes on surrogate primary keys (IDENTITY columns) by default, relegating natural or business keys to UNIQUE constraints.
- Metadata Auditability: Establishes mandatory system audit columns (CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME() and ModifiedAt DATETIME2 NULL) for all transactional tables to track state progression.
- Historical Tracking: Mandates explicit database modeling patterns for state/history tracking (using dedicated historical tables or SQL Server temporal tables) rather than mutating statuses in place.
- Data Retention Policy: Defines explicit delete strategies, standardizing on soft-delete mechanisms (IsActive / DeletedAt) for reference data, and restricting hard-deletes to transient data.
- Lexical Conventions: Enforces a strict PascalCase naming convention across all relational entities and attributes.
## 2. Risk Mitigation and Ambiguity Tiering
- While version 1 recommended continuing with generic assumptions during requirements gaps, this version implements a structured governance protocol for handling system ambiguities:
- Two-Tier Ambiguity Classification: Gaps are partitioned into Minor Gaps (non-structural items that are resolved via logged assumptions) and Structural Gaps (core business rule changes or schema-altering ambiguities).
- Escalation Protocol: Structural gaps trigger an immediate execution halt and user escalation mechanism, preventing downstream logic corruption and minimizing rework cycles.
## 3. Relational Idempotency and State-Awareness
- This version incorporates operational parameters for execution safety and iterative updates (reruns):
- State Verification: Prior to design execution, the directory state is mapped via file-system discovery (ls -la) to identify existing artifacts.
- Idempotent DDL Execution: Requires DROP TABLE IF EXISTS statements in the database definition script, structured in reverse-dependency order, to allow safe, repeatable execution.
- Downstream Change Propagation: Establishes a strict change management rule: any mutation in an early phase (e.g., conceptual design) must dynamically propagate to and invalidate downstream deliverables (logical design, DDL, queries) to prevent architectural drift.
- Code Conservation Guard: Prevents the silent clobbering of manually edited files, requiring the system to flag discrepancies before overwriting.
## 4. Requirement Traceability and Validation Rigor
- The validation phase (Step 4) is heavily refactored in this version to enforce data integrity and functional correctness:
- Mandatory Traceability Matrix: Replaces narrative prose validation with a structured, tabular mapping matrix (Requirement ID  Entity  Relationship  Table  Constraint).
- Procedural Guardrails: Introduces a strict feedback loop. If the validation step identifies structural gaps, contradictions, or design limitations, the protocol mandates a rollback to Steps 1–3 to correct the schema before generating the SQL definition.
## 5. Script Optimization and Deliverable Expansion
- The final relational script deliverables (Steps 5, 6, and 7) are expanded to ensure comprehensive testing and localization:
- Database Isolation: Adds CREATE DATABASE safety logic to prevent namespace conflicts by dynamically utilizing version-controlled schemas (e.g., CampusSpaceManagement_v2).
- Seed Data Alignment & Localization: Mandates that sample data reflect local Vietnamese contexts where appropriate and requires strict transactional alignment with query files to guarantee non-empty result sets during testing.
- Expanded Query Coverage: Doubles the deliverable requirement from a minimum of five queries in version 1 to a minimum of ten complex queries in this version, specifically targeting high-complexity scenarios (e.g., resource utilization, concurrent booking conflicts, and status transitions).
## 6. Execution Verification Loop and Definition of Done (DoD)
- This version closes the development lifecycle with an automated execution verification phase (Step 8) and a formal Definition of Done (DoD):
- Compilation and Integration Testing: Requires a full compilation check of the generated SQL scripts against an active SQL Server instance to verify relational integrity, foreign key dependency order, and execution logic.
- Output Validation: Mandates that every designed analytical query return a valid, non-empty schema result when run against the generated mock dataset before the development cycle is declared complete.
