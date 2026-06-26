# AGENTS.md — cs486-demo

CS486 database systems teaching demo. Repository is empty; expect code to be added during sessions.

## Recurring context

- Root directory: D:\University\Y2T3 - Introduction to Database Systems\Lab\Project\DatabaseProj
- This is a demo project, not production.
- Run `ls -la` to detect new files before assuming anything exists.

# Database Design Agent Rules

This project transforms business requirements into database design artifacts.

## Project-Specific Constraints
- **CRITICAL RULE:** This group is Group 04. All generated output files MUST be placed exclusively in the `outputs/` folder and the filename MUST end with `-G04` before the extension.

## Workflow Order
Always follow this order:

1. Analyze business requirements.
2. Produce conceptual ERD using Crow's Foot notation.
3. Logical Database Design.
4. Database Design Validation.
5. Database Implementation (DDL).
6. Sample Data Preparation.
7. Query Design.

Do not jump directly to DDL. The documents from the prior steps should be followed in the later steps.

## Required Outputs

- `outputs/01-business-req-analysis-G04.md`
- `outputs/02-erd-design-G04.md`
- `outputs/03-logical-design-G04.md`
- `outputs/04-design-validation-G04.md`
- `outputs/05-db-definition-G04.sql`
- `outputs/06-sample-data-G04.sql`
- `outputs/07-query-design-G04.sql`

## DBMS

Use Microsoft SQL Server unless the user specifies another DBMS.

## Design Rules

- Record assumptions explicitly.
- Record open questions explicitly.
- Preserve traceability from requirement → entity → relationship → table → constraint.
- Use Mermaid `erDiagram` for ERD.
- Do not silently invent business rules.