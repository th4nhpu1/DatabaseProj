---
name: db-design-pipeline
description: Analyze business requirements and produce 7 comprehensive database design deliverables under outputs/.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform business requirements into a full database design.

## Important behavior

Before assuming anything, inspect the project:

1. Run `ls -la`.
2. Locate requirement files under `req/`, `docs/`, or files passed by the user.
3. Read the relevant requirement files fully before designing.
4. If the requirement is incomplete, continue with explicit assumptions, but also create an unresolved questions section.

### DeepSeek Optimization

- Avoid any conversational filler, meta-commentary, or introductory chat (e.g., 'Sure, here is the design...'). Output ONLY the requested clean Markdown structure or raw executable SQL code blocks.
- Enforce strict, standard, syntax-valid SQL syntax with explicit data types and relational constraints tailored for high performance.

## Required output files

Create or update the following 7 files under `outputs/`:

1. `outputs/01-business-req-analysis-G04.md`
2. `outputs/02-erd-design-G04.md`
3. `outputs/03-logical-design-G04.md`
4. `outputs/04-design-validation-G04.md`
5. `outputs/05-db-definition-G04.sql`
6. `outputs/06-sample-data-G04.sql`
7. `outputs/07-query-design-G04.sql`

Do not skip any file. Do not use placeholders.

---

# Step 1: Business Requirement Analysis

Save to:

`outputs/01-business-req-analysis-G04.md`

The document must include:

- Project name and date
- Stakeholders identified
- Functional requirements extracted from the business requirement, listed in a table with ID, description, and priority
- Non-functional requirements
- Entities identified (nouns from the requirements)
- Relationships identified (verb phrases connecting nouns)
- Assumptions made
- Open questions / unresolved items

---

# Step 2: Conceptual Design / ERD

The ERD should be based on the document from Step 1.

Save to:

`outputs/02-erd-design-G04.md`

The document must include:

- Explanation of each entity and its attributes
- Explanation of each relationship (including cardinalities using Crow's Foot notation)
- Mermaid `erDiagram` block showing the conceptual model
- Key business rules captured from requirements (e.g., no overlapping bookings, maintenance blocks booking)
- Assumptions and open questions preserved from Step 1

---

# Step 3: Logical Design

Based on the Conceptual ERD from Step 2.

Save to:

`outputs/03-logical-design-G04.md`

The document must include:

- Mapping each entity to a relational table (table name, column names, data types with lengths, nullability, primary keys, foreign keys)
- All intermediate tables for many-to-many relationships (e.g., SpaceFacility linking spaces to facilities)
- A table listing all tables with: table name, description, estimated row count, and growth pattern
- Referential integrity rules (ON DELETE / ON UPDATE actions)
- Assumptions and open questions

---

# Step 4: Normalization

Based on the Logical Design from Step 3.

Save to:

`outputs/04-design-validation-G04.md`

The document must include:

- Check each table against 1NF, 2NF, 3NF (and BCNF if applicable)
- Show the current normal form for every table
- If any table is not in 3NF, show the decomposition steps to reach 3NF
- Final schema after normalization (if changes were needed)
- Explanation of why denormalization was not chosen (or if it was, the justification)
- Assumptions

---

# Step 5: DDL Schema (Pure SQL)

Based on the normalized Logical Design from Step 4.

Save to:

`outputs/05-db-definition-G04.sql`

The document must include:

- Complete `CREATE TABLE` statements for Microsoft SQL Server, with:
  - Appropriate data types (e.g., `NVARCHAR(100)`, `DATETIME2`, `INT`, `DECIMAL(10,2)`, `BIT`)
  - `NOT NULL` and `NULL` constraints
  - `PRIMARY KEY` and `FOREIGN KEY` constraints (inline or out-of-line)
  - `DEFAULT` values where applicable
  - `CHECK` constraints where applicable
  - `UNIQUE` constraints where applicable
- If the DBMS is not specified, use Microsoft SQL Server.
- All table creation order must respect foreign key dependencies (parents before children).
- Include a `-- Create tables in dependency order --` comment header.
- Assumptions

---

# Step 6: Sample Data (Pure SQL INSERT)

Based on the DDL Schema from Step 5.

Save to:

`outputs/06-sample-data-G04.sql`

The document must include:

- Realistic INSERT statements for all tables, covering normal operational cases and exceptional/boundary-testing cases
- Insert order must respect FK dependencies (parents before children)
- At minimum: 10+ users with varied roles, 8+ spaces including some under maintenance/closed/retired, 6+ facility types, space-facility assignments, 10+ bookings spanning all statuses (pending, approved, rejected, cancelled, checked_in, completed, no_show), corresponding approvals, check-ins, check-outs, and 5+ maintenance records
- Exceptional cases: overlapping booking attempt, booking for a space under maintenance, suspended user, retired space
- Each INSERT prefixed with a brief inline comment describing the scenario

---

# Step 7: Query Design (Pure SQL)

Based on the full schema from Steps 5 and 6.

Save to:

`outputs/07-query-design-G04.sql`

The document must include:

- At least 10 business-relevant SQL queries that answer real questions the School would ask, such as:
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
- Each query must have a header comment block containing:
  - Business question (in plain English)
  - Target user (who would run this query)
  - Explanation of the logic
- Each query must use DECLARE parameters for filter values (parameterized)
- All SQL must be syntax-valid T-SQL for Microsoft SQL Server
