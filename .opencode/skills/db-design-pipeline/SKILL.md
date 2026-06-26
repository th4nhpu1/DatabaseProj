---
name: db-design-pipeline
description: Analyze business requirements and produce conceptual ERD, logical database design, and DDL documents step by step.
compatibility: opencode
---

# Database Design Pipeline Skill

Use this skill when the user asks to transform business requirements into a database design.

## Important behavior
Before assuming anything, inspect the project:
1. Run `ls -la`.
2. Locate requirement files under `req/`.
3. Read the relevant requirement files fully before designing.
4. All outputs MUST be saved in the `outputs/` folder.

---

# Step 1: Business Requirement Analysis
Save to: `outputs/01-business-req-analysis-G04.md`

The document must include:
- Actors & Roles.
- Entities & Attributes.
- Relationships.

# Step 2: Conceptual Design / ERD
Save to: `outputs/02-erd-design-G04.md`

The document must include:
- A Mermaid.js `erDiagram` block.

# Step 3: Logical Database Design
Save to: `outputs/03-logical-design-G04.md`

The document must include:
- Relational schema derived from the conceptual design.
- List all Tables, Attributes, Primary Keys, and Foreign Keys.

# Step 4: Database Design Validation
Save to: `outputs/04-design-validation-G04.md`

The document must include:
- A brief evaluation of the design from Step 3.

# Step 5: Database Implementation (DDL)
Save to: `outputs/05-db-definition-G04.sql`

The script must include:
- `CREATE TABLE` statements for Microsoft SQL Server.

# Step 6: Sample Data Preparation
Save to: `outputs/06-sample-data-G04.sql`

The script must include:
- `INSERT` statements with sample data for all tables.

# Step 7: Query Design
Save to: `outputs/07-query-design-G04.sql`

The file must contain exactly 5 SQL queries to answer business questions.