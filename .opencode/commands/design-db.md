---
description: Run the database design pipeline from a business requirement file
---

Use the database design pipeline skill in:

`.opencode/skills/db-design-pipeline/SKILL.md`

Read the business requirement and project brief from the file passed in `$ARGUMENTS`.

If the argument is missing or points to an incomplete requirement file, also read:

- `CS486_Project.pdf`
- `req/business-requirement.md`


Run the full Phase 1 pipeline and generate or update all required outputs in `outputs/`:
1. `01-business-req-analysis-G4.md`
2. `02-erd-design-G4.md`
3. `03-logical-design-G4.md`
4. `04-design-validation-G4.md`
5. `05-db-definition-G4.sql`
6. `06-sample-data-G4.sql`
7. `07-query-design-G4.sql`

Keep the deliverables consistent with the PDF instructions, the repository AGENTS file, and the database design skill rules.