---
name: db-design-pipeline
description: Analyze business requirements and produce the full Phase 1 database design package for the Campus Space Management System — business requirement analysis, ERD, logical design, validation, SQL Server DDL, sample data, and query design. Use this whenever the user asks to turn the Campus Space Management System requirement into database design deliverables, asks to regenerate/update any of the seven numbered output files, or asks to validate/extend the existing schema for that system. Do not use this for unrelated database questions, generic SQL help, or changes to an already-deployed production schema outside this project's scope.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform the Campus Space Management System requirement into database design deliverables.

## Project conventions (set once, apply everywhere)

These are fixed for this project. Do not redecide them per run — apply consistently across all seven outputs.

- **DBMS**: Microsoft SQL Server, unless the user explicitly asks for another DBMS.
- **Naming case**: PascalCase for tables and columns (e.g. `BookingRequest`, `RequestedBy`).
- **Keys**: surrogate integer/`IDENTITY` primary keys by default; natural/business keys become `UNIQUE` constraints, not primary keys, unless the requirement explicitly demands otherwise.
- **Audit columns**: every transactional table (bookings, approvals, maintenance, check-ins) gets `CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()` and `ModifiedAt DATETIME2 NULL`.
- **History tracking**: model status/history explicitly with a dedicated history table (e.g. `BookingStatusHistory`) rather than overwriting status in place, unless the user asks for SQL Server temporal tables instead — state which approach was used in the ERD and logical design docs.
- **Deletes**: soft-delete (`IsActive` / `DeletedAt`) for reference and space data; hard-delete only for genuinely transient data, and call out which tables use which policy.

## Before starting

1. Run `ls -la`.
2. Locate the requirement sources under `req/`, the PDF in the project root, and any file passed by the user.
3. Read the relevant requirement sources fully before designing.
4. Check `outputs/` for existing files from a prior run. If present, treat this as an update, not a fresh generation — see "Handling reruns" below.
5. If the requirement is incomplete, classify the gap (see "Handling ambiguity") before deciding whether to assume or stop and ask.
6. Preserve traceability from requirement to entity to relationship to table to constraint — this must end up as an actual table in Step 4, not just narrative description.

## Handling ambiguity

Not all gaps are equal. Split them into two tiers:

- **Minor (default and proceed)**: things like a default booking duration, a specific status label, or a non-binding formatting choice. Make an explicit assumption, log it in the relevant output file's "Assumptions" section, and continue.
- **Structural (stop and ask)**: anything that would change the shape of the schema or core business rules — e.g. whether a space can have multiple concurrent bookings under different approval authorities, whether maintenance blocks are hard locks or soft warnings, or whether cancellations/no-shows need to be reversible. For these, pause after Step 1 and ask the user directly rather than guessing; a wrong structural assumption propagates into every later file and the generated SQL.

## Handling reruns

If `outputs/` already contains files from a previous run:

- Diff the current requirement sources against what the existing outputs imply before rewriting anything.
- Update only the files affected by the change, per the "Output quality rules" below — but if a change to an early file (e.g. the ERD) invalidates a later one (e.g. the DDL), update everything downstream of it too, don't leave them inconsistent.
- Don't silently overwrite a file that contains content not derivable from the requirement docs — that may be a manual edit. Flag the discrepancy to the user instead of clobbering it.

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
- Assumptions (tagged minor vs structural, per "Handling ambiguity")
- Open questions or ambiguities, that couldn't be resolved from the requirement sources, tagged as needing user input before proceeding with design
- Requirement traceability notes

# Step 2: Conceptual Design / ERD

Base the ERD on the approved requirement analysis from Step 1.

Save to `outputs/02-erd-design-G4.md`.

The document must include:

- A Mermaid `erDiagram` (validate the Mermaid syntax mentally or by rendering it — don't ship unparseable diagram code)
- Main entities with identifiers and key attributes
- Relationship names, cardinalities, and participation constraints
- Notes for optionality, historical tracking, and status-driven behavior — state explicitly whether history is modeled via a history table or temporal table, per project conventions
- Assumptions that affect conceptual design
- Confirmation that conflicting bookings, maintenance blocks, and status transitions are structurally represented in the schema rather than left as application logic

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
- Confirmation that naming, key, audit-column, and delete-policy conventions (above) were applied consistently


# Step 4: Database Design Validation

Validate the logical schema against the requirements.

Save to `outputs/04-design-validation-G4.md`.

The document must include:

- A **requirement-to-schema traceability matrix** (Requirement ID → Entity → Relationship → Table → Constraint) as an actual table, not just prose
- Validation of business rules and constraints
- Identification of any unresolved gaps or assumptions
- Discussion of conflicting bookings, maintenance blocks, and status transitions. Make sure these are structurally represented in the schema (e.g. via a status history table) rather than just described in prose.
- Any limitations that require application logic or advanced SQL Server features

**If this step finds a gap, contradiction or limitation, go back and fix Steps 1–3 before proceeding to Step 5.** Do not carry a known schema problem forward into the DDL.

# Step 5: Database Definition

Implement the relational design as SQL Server DDL.

Save to `outputs/05-db-definition-G4.sql`.

The script must include:

- `CREATE DATABASE` statement with the name `CampusSpaceManagement`, if that name already exists, use `CampusSpaceManagement_v2` or similar to avoid conflicts
- `CREATE TABLE` statements, ordered so foreign-key dependencies are created before the tables that reference them
- Before creating tables, add `DROP TABLE IF EXISTS` statements to allow clean re-runs without manual cleanup
- Primary keys and foreign keys
- `CHECK`, `DEFAULT`, and `UNIQUE` constraints where appropriate
- Data types suitable for SQL Server
- Any needed lookup tables or seed-independent reference structures
- Audit columns and delete-policy columns per project conventions
- Comments only when needed for clarity

# Step 6: Sample Data Preparation

Prepare realistic sample data for testing.

Save to `outputs/06-sample-data-G4.sql`.

The script must include:

- Inserts ordered to satisfy foreign-key dependencies (parents before children)
- Inserts for normal cases
- Inserts for important edge cases
- Data that supports bookings, approvals, maintenance, check-in, completion, and no-show scenarios
- Sample data that helps verify constraint behavior and history reporting
- Sample data that allows the queries in Step 7 to return meaningful results
- Sample data should be in Vietnamese where appropriate to reflect the local context, but can be in English if the requirement sources are in English or if it helps clarify the data's purpose

# Step 7: Query Design

Create at least ten meaningful SQL queries for the database.

Save to `outputs/07-query-design-G4.sql`.

Each query section must include:

- Business question
- Target user(s)
- Short explanation of usefulness
- SQL statement

The queries should support questions such as booking history, upcoming bookings, spaces under maintenance, utilization, no-show bookings, conflicting bookings and status transitions.
If the query returns no result, go back to Step 6 and add sample data to ensure it does, unless the requirement explicitly allows for empty results in that case.

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