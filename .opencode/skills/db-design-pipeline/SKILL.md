---
name: db-design-pipeline
description: Analyze business requirements and produce the full Phase 1 database design package for the Campus Space Management System (V3.0 Ultimate).
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform the Campus Space Management System requirement into database design deliverables.

## Project Conventions (Set once, apply everywhere)

1. **Group Identity:** All required filenames must end with `-G04` before the extension.
2. **DBMS:** Microsoft SQL Server.
3. **LLM Optimization:** Avoid conversational filler, meta-commentary, and introductory chat. Output ONLY the requested Markdown structure or raw executable SQL code blocks.
4. **Naming Case:** PascalCase for tables and columns (e.g., `BookingRequest`, `RequestedBy`).
5. **Keys:** Surrogate integer `IDENTITY(1,1)` primary keys by default. Natural/business keys become `UNIQUE` constraints.
6. **Audit Columns:** Every transactional table MUST have `CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()` and `ModifiedAt DATETIME2 NULL`.
7. **Deletes:** Use Soft-delete (`IsActive BIT DEFAULT 1` or `DeletedAt DATETIME2 NULL`) for reference and space data.
8. **Formatting:** Ensure strict standard ASCII spaces for indentation. Remove non-breaking spaces from Mermaid and SQL output.

---

# Step 1: Business Requirement Analysis

- **Input:** Requirement files under `req/`, the PDF in the project root, or any document passed by the user.
- **Output:** `outputs/01-business-req-analysis-G04.md`
- **Requirement:** 
- Extract and list all stakeholders and user roles.
  - Identify main entities and candidate attributes (Explicitly tag entities that require audit and history tracking).
  - Define core relationships and cardinalities (Map operational actions like check-in/check-out).
  - List strict business rules, specifically addressing: overlapping bookings, unavailable space handling, and conditional approvals.
  - Document assumptions and classify them as "Minor" or "Structural".
  - Create a Requirement Traceability Matrix (mapping Req ID to Entities).

# Step 2: Conceptual Design / ERD

- **Input:** The approved Business Requirement Analysis from Step 1.
- **Output:** `outputs/02-erd-design-G04.md`
- **Requirement:** - Generate a Mermaid `erDiagram` block using standard ASCII spaces only.
  - **CRITICAL MERMAID SYNTAX RULE:** If an attribute has multiple constraints, separate them with a comma and space (e.g., `int booking_id FK, UK`, NEVER use `FK UK`).
  - Provide a text explanation for each entity and relationship using Crow's Foot notation cardinality.
  - Ensure historical tracking and audit relationships are explicitly drawn (e.g., separate "checks in" and "checks out" relationships).

# Step 3: Logical Database Design

- **Input:** The Conceptual ERD from Step 2.
- **Output:** `outputs/03-logical-design-G04.md`
- **Requirement:** 
  - Convert entities into a relational schema format mapping table names, columns, data types, nullability, and keys (PK/FK).
  - Create intermediate tables for M:N relationships (e.g., `SpaceFacility`).
  - Explicitly apply Project Conventions (PascalCase, surrogate keys, `CreatedAt`/`ModifiedAt` audit columns, Soft-delete columns).
  - Document referential integrity rules (ON DELETE / ON UPDATE actions).

# Step 4: Normalization & Validation

- **Input:** The Logical Database Design from Step 3 and Requirements from Step 1.
- **Output:** `outputs/04-design-validation-G04.md`
- **Requirement:** 
- **Normalization Check:** Evaluate every table against 1NF, 2NF, and 3NF. Explicitly write down the decomposition steps if any table violates 3NF.
  - **Traceability Verification:** Present a matrix mapping Requirement ID -> Entity -> Table -> Constraint.
  - **Business Logic Validation:** Explicitly explain how the schema handles:
    1. Conditional/optional approvals (0-or-1 relationships).
    2. Multiple overlapping requests that are currently in the 'Pending' state.
  - Document any limitations that force reliance on Application Logic or Triggers.

# Step 5: Database Definition (DDL)

- **Input:** The Normalized Schema from Step 4.
- **Output:** `outputs/05-db-definition-G04.sql`
- **Requirement:** 
  - Include a `CREATE DATABASE CampusSpaceManagement;` statement (use `_v2` dynamically if needed to prevent dropping existing DBs).
  - Write `DROP TABLE IF EXISTS` statements in reverse dependency order.
  - Write `CREATE TABLE` statements in correct dependency order (parents before children).
  - **CRITICAL TRIGGER REQUIREMENTS (Business Rules):** You MUST write `CREATE TRIGGER` statements (`AFTER INSERT, UPDATE`) to enforce:
    1. *Overlap Prevention:* Rollback if a new booking overlaps in time with any 'approved'/'checked_in' booking for the same space.
    2. *Unavailable Space Block:* Rollback if the booked space status is under maintenance, closed, or retired.
    3. *Capacity Enforcement:* Rollback if `ExpectedParticipants` exceeds the space's `Capacity`.
  - **CRITICAL TRIGGER REQUIREMENTS (Audit):** Write `AFTER UPDATE` triggers for all tables to auto-update the `ModifiedAt` timestamp.

# Step 6: Sample Data Preparation

- **Input:** The DDL Schema from Step 5.
- **Output:** `outputs/06-sample-data-G04.sql`
- **Requirement:** 
  - Write `INSERT` statements with a minimum scale: 10+ users, 8+ spaces, 6+ facilities, 10+ bookings (covering all statuses), and 5+ maintenance records. Use localized Vietnamese names.
  - **CRITICAL CHRONOLOGICAL INTEGRITY:** Past bookings must be in resolved states (Completed, Cancelled, NoShow). Future bookings must be Pending or Approved. Do not record actual check-ins for future dates.
  - **CRITICAL LIFECYCLE SIMULATION:** Insert records as 'Pending' initially, then use sequential `UPDATE` statements to transition their statuses to trigger the audit history properly.
  - **CRITICAL DATA VALIDATION RULE:** Ensure generated data DOES NOT violate the Triggers defined in Step 5.
  - Include a section at the bottom for "Negative Test Cases" (commented-out inserts that intentionally fail business rules, with explanatory comments).

# Step 7: Query Design

- **Input:** The DDL from Step 5 and Sample Data from Step 6.
- **Output:** `outputs/07-query-design-G04.sql`
- **Requirement:** 
  - Write at least 10 meaningful SQL queries answering real operational questions (e.g., utilization rates, pending queues, maintenance logs):
    1. List all available spaces for a given time range
    2. Find conflicting bookings for a space
    3. View booking history of a user
    4. View upcoming approved bookings for a space
    5. Find spaces currently under maintenance
    6. Generate a utilization report (used hours / available hours per space)
    7. List all bookings checked in but not completed (no-show risk)
    8. Find the most frequently booked space type
    9. Get maintenance history for a specific space
    10. List pending bookings that need approval
  - Include a header for each query containing: Business Question, Target User, and Logic Explanation.
  - **CRITICAL PARAMETERIZATION:** Do not hardcode filter IDs. You MUST use `DECLARE @VariableName Type = Value;` for all `WHERE` clause filters.
  - **CRITICAL EMPTY RESULT PREVENTION:** Mentally execute the query against the Step 6 data using the current real-world date. Ensure the queries return sensible, non-empty results.

# Step 8: Execution Verification

Before declaring the pipeline complete, verify the SQL actually works — don't just generate it and stop.

- Run `outputs/05-db-definition-G4.sql` against a real or containerized SQL Server instance (or at minimum a syntax/lint check if no instance is available) and resolve any errors.
- Run `outputs/06-sample-data-G4.sql` against the resulting schema and confirm it inserts cleanly in dependency order.
- Run each query in `outputs/07-query-design-G4.sql` against the populated sample data and confirm each returns a sensible, non-empty result where one is expected.
- Fix and re-run rather than reporting success on ungenerated/untested SQL.

---

# Definition of done

The pipeline is complete only when all of the following hold:

- All seven (plus this verification pass) required files exist and are internally consistent with each other
- Step 4's traceability matrix has no unresolved structural gaps blocking implementation
- The DDL and sample data scripts execute without error per Step 8
- All five-plus queries return correct, sensible results against the sample data

# Output quality rules

- Keep naming and the output suffix consistent across all outputs.
- Do not silently invent business rules — structural ambiguities get escalated per "Handling ambiguity," not guessed at.
- If the PDF and requirement file differ, call out the discrepancy and state the assumption used.
- Prefer concise, readable Markdown and SQL.
- Update only the files needed for the requested scope unless the user explicitly asks for a broader regeneration — but always propagate fixes downstream if an earlier file changes (see "Handling reruns").