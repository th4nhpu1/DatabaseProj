---
name: db-design-pipeline
description: Analyze business requirements and produce the full Phase 1 database design package for the Campus Space Management System.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform the Campus Space Management System requirement into database design deliverables.

## Important behavior

Before assuming anything, inspect the project:

1. Run `ls -la`.
2. Locate the requirement sources under `req/`, the PDF in the project root, and any file passed by the user.
3. Read the relevant requirement sources fully before designing.
4. If the requirement is incomplete, continue with explicit assumptions and an unresolved questions section.
5. Preserve traceability from requirement to entity to relationship to table to constraint.
6. Use Microsoft SQL Server unless the user explicitly asks for another DBMS.

## Required output files

Create or update the following files:

1. `outputs/01-business-req-analysis-G4.md`
2. `outputs/02-erd-design-G4.md`
3. `outputs/03-logical-design-G4.md`
4. `outputs/04-design-validation-G4.md`
5. `outputs/05-db-definition-G4.sql`
6. `outputs/06-sample-data-G4.sql`
7. `outputs/07-query-design-G4.sql`

Do not skip any required artifact.

---

# Step 1: Business Requirement Analysis

Save to `outputs/01-business-req-analysis-G4.md`.

The document must include:

- Business purpose of the system
- Stakeholders and user roles
- Main business processes and operational goals
- Entities and candidate attributes
- Core relationships and cardinalities
- Business rules and constraints, including booking conflicts and unavailable space rules
- Assumptions
- Open questions or ambiguities
- Requirement traceability notes

# Step 2: Conceptual Design / ERD

Base the ERD on the approved requirement analysis from Step 1.

Save to `outputs/02-erd-design-G4.md`.

The document must include:

- A Mermaid `erDiagram`
- Main entities with identifiers and key attributes.
- **CRITICAL MERMAID SYNTAX RULE:** If an attribute has multiple constraints (e.g., both Foreign Key and Unique Key), you MUST separate them with a comma and space. 
  -  Correct: `int booking_id FK, UK`
  -  Incorrect: `int booking_id FK UK` (This causes parse errors).
- Relationship names, cardinalities, and participation constraints.
- Notes for optionality, historical tracking, and status-driven behavior.
- Assumptions that affect conceptual design.

# Step 3: Logical Database Design

Convert the ERD into a relational schema.

Save to `outputs/03-logical-design-G4.md`.

The document must include:

- Relations with attributes
- Primary keys and foreign keys
- Candidate keys and alternate keys when relevant
- Nullability and uniqueness decisions
- Mapping notes from conceptual entities and relationships
- Constraint rationale for booking and maintenance history

# Step 4: Database Design Validation

Validate the logical schema against the requirements.

Save to `outputs/04-design-validation-G4.md`.

The document must include:

- Coverage check from requirement to schema
- Validation of business rules and constraints
- Identification of any unresolved gaps or assumptions
- Discussion of conflicting bookings, maintenance blocks, and status transitions
- Any limitations that require application logic or advanced SQL Server features

# Step 5: Database Definition

Implement the relational design as SQL Server DDL.

Save to `outputs/05-db-definition-G4.sql`.

The script must include:

- `CREATE TABLE` statements
- Primary keys and foreign keys
- `CHECK`, `DEFAULT`, and `UNIQUE` constraints where appropriate
- Data types suitable for SQL Server
- Any needed lookup tables or seed-independent reference structures
- Comments only when needed for clarity

# Step 6: Sample Data Preparation

Prepare realistic sample data for testing.

Save to `outputs/06-sample-data-G4.sql`.

The script must include:

- Inserts for normal cases
- Inserts for important edge cases
- Data that supports bookings, approvals, maintenance, check-in, completion, and no-show scenarios
- Sample data that helps verify constraint behavior and history reporting

# Step 7: Query Design

Create at least five meaningful SQL queries for the database.

Save to `outputs/07-query-design-G4.sql`.

Each query section must include:

- Business question
- Target user(s)
- Short explanation of usefulness
- SQL statement

The queries should support questions such as booking history, upcoming bookings, spaces under maintenance, utilization, and no-show bookings.

---

# Output quality rules

- Keep the naming consistent across all outputs.
- Do not silently invent business rules.
- If the PDF and requirement file differ, call out the discrepancy and state the assumption used.
- Prefer concise, readable Markdown and SQL.
- Update only the files needed for the requested scope unless the user explicitly asks for a broader regeneration.