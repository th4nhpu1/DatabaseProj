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

## Required output files

Create or update the following 7 files under `outputs/`:

1. `outputs/01-business-requirement-analysis.md`
2. `outputs/02-conceptual-design-erd.md`
3. `outputs/03-logical-design.md`
4. `outputs/04-normalization.md`
5. `outputs/05-ddl-schema.md`
6. `outputs/06-constraints-indexes.md`
7. `outputs/07-query-design.md`

Do not skip any file. Do not use placeholders.

---

# Step 1: Business Requirement Analysis

Save to:

`outputs/01-business-requirement-analysis.md`

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

`outputs/02-conceptual-design-erd.md`

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

`outputs/03-logical-design.md`

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

`outputs/04-normalization.md`

The document must include:

- Check each table against 1NF, 2NF, 3NF (and BCNF if applicable)
- Show the current normal form for every table
- If any table is not in 3NF, show the decomposition steps to reach 3NF
- Final schema after normalization (if changes were needed)
- Explanation of why denormalization was not chosen (or if it was, the justification)
- Assumptions

---

# Step 5: DDL Schema

Based on the normalized Logical Design from Step 4.

Save to:

`outputs/05-ddl-schema.md`

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

# Step 6: Constraints and Indexes

Based on the DDL Schema from Step 5.

Save to:

`outputs/06-constraints-indexes.md`

The document must include:

- List of all primary key constraints (table, column(s), constraint name)
- List of all foreign key constraints (table, column(s), references, ON UPDATE, ON DELETE)
- List of all unique constraints (table, column(s), purpose)
- List of all check constraints (table, column(s), condition, purpose)
- List of recommended indexes (non-clustered) for performance, with columns and justification (based on query patterns: lookups by foreign key, filtering by status/dates, etc.)
- List of default values
- Complete T-SQL script that can be run after the DDL to add all non-schema-definable constraints (e.g., filtered indexes)
- Assumptions

---

# Step 7: Query Design

Based on the full schema from Steps 5 and 6.

Save to:

`outputs/07-query-design.md`

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
- Each query must include:
  - Business question (in plain English)
  - SQL query (T-SQL syntax)
  - Explanation of what the query does
- Include a section with parameterized versions of key queries (for use in application code)
- Assumptions
