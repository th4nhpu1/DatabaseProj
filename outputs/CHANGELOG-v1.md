# CHANGELOG — v2 (DeepSeek Migration)

## 1. Model Migration: Big Pickle → DeepSeek V4

| Aspect | v1 (Big Pickle) | v2 (DeepSeek V4) |
|---|---|---|
| Generator | Big Pickle (pre-DeepSeek) | DeepSeek V4 |
| Output style | Verbose sections with tables, lengthy explanations | Concise structured markdown and raw SQL, zero conversational filler |
| SKILL.md | Plain behavioral instructions | Added **DeepSeek Optimization** subsection banning meta-commentary and enforcing strict syntax-valid SQL |
| Code generation | Mixed Markdown narrative with embedded code | Raw SQL `.sql` files for deliverables 5–7; Markdown only for analysis documents |

## 2. Architecture Updates

### Entity / Table Changes

| File | v1 → v2 Change |
|---|---|
| `03-logical-design-G04.md` | FK columns now explicitly list referenced parent columns (e.g., `FK → User(userId)` instead of `FK → User`) |
| `03-logical-design-G04.md` | `DEFAULT GETUTCDATE()` → `DEFAULT SYSUTCDATETIME()` (MS SQL Server canonical form) |
| `03-logical-design-G04.md` | Removed standalone "Assumptions" section (redundant — covered in earlier docs) |
| `03-logical-design-G04.md` | Section headers flattened from `## Table: X` to `### X` (consistent subordination) |
| `04-design-validation-G04.md` | Replaced tabular NF-check layout with compact bullet-list format (~60 % shorter) |
| `04-design-validation-G04.md` | Removed "Denormalization Decision" prose block — replaced with single-sentence summary |
| `04-design-validation-G04.md` | Removed separate "Assumptions" section (answers unchanged, moved inline) |

### Structural Constraints

| Constraint | v1 | v2 |
|---|---|---|
| `Booking.submittedAt` | `DEFAULT GETUTCDATE()` | `DEFAULT SYSUTCDATETIME()` |
| `CK_User_accountStatus` | Multi-line value list | Single-line value list |
| `CK_Space_currentStatus` | Multi-line value list | Single-line value list |
| DDL file separators | Verbatim `-- ===== Heading =====` blocks | Inline `-- N. TableName (dependencies)` comments |
| Blank lines around constraint blocks | Present | Removed (tighter SQL) |

## 3. SQL Improvements

### Query Optimization in `07-query-design-G04.sql`

| Aspect | v1 | v2 |
|---|---|---|
| Query header format | Business question + Explanation only | **Business question** + **Target user** + **Explanation** |
| Parameterization | Standalone section at end | `DECLARE @Param` at top of **every** query |
| Subquery formatting | `SELECT 1` on its own line + indented `FROM` | Compact `SELECT 1 FROM [Table]` (single line) |
| Q8 (avg hours) | Nested `ROUND(...)` on 6 lines | Compact single-line `ROUND(...)` expression |
| Q6 (utilization) | Nested `ROUND(...)` on 8 lines | Compact single-line `ROUND(...COALESCE(...) / 720.0 * 100, 2)` |
| Q5 (maintenance spaces) | `m.recordId, m.problemDescription,` on separate line from `m.startTime` | All three on same line |
| Overall comment density | Verbose explanation paragraphs | Tighter, single-sentence explanations |

### Data Integrity in `06-sample-data-G04.sql`

| Aspect | v1 | v2 |
|---|---|---|
| INSERT grouping | Individual INSERT per record (many `VALUES` blocks) | Batched `INSERT ... VALUES (...), (...)` for each table |
| Sample count | 10 users, 9 spaces, 24 SF rows, 13 bookings, 6 approvals, 3 check-ins, 2 check-outs, 5 maintenance | Same data volume, fewer redundant comment separators |
| Inline comments | Section headers and per-record comments | Compact inline comments without separator banners |
| Maintenance record #1 | Contained non-ASCII text (`漏水`) | Replaced with plain English `Ceiling water leak` |
| Booking purpose strings | Contained dashes (`Database Systems - Week 1`) | Replaced with plain spaces (`Database Systems Week 1`) |

### DDL Cleanliness in `05-db-definition-G04.sql`

| Aspect | v1 | v2 |
|---|---|---|
| Table header comments | `-- ===== N. Name =====` (heavy banner) | `-- N. Name (dependencies)` (inline) |
| Blank lines after column lists | Present before `CONSTRAINT` block | Removed |
| CHECK value lists | Multi-line `IN (...)` | Single-line `IN (...)` |

## 4. Formatting Fixes (File Naming & Extensions)

| v1 Filename | v2 Filename | Reason |
|---|---|---|
| `01-business-requirement-analysis.md` | `01-business-req-analysis-G04.md` | Group suffix `-G04`; shorted name |
| `02-conceptual-design-erd.md` | `02-erd-design-G04.md` | Group suffix `-G04`; shorted name |
| `03-logical-design.md` | `03-logical-design-G04.md` | Group suffix `-G04` |
| `04-normalization.md` | `04-design-validation-G04.md` | Renamed to match assignment rubric (`design-validation`) |
| `05-ddl-schema.md` | `05-db-definition-G04.sql` | Extension `.md` → `.sql`; renamed to match rubric (`db-definition`) |
| `06-constraints-indexes.md` | `06-sample-data-G04.sql` | Replaced entirely (constraints-indexes → sample-data); `.md` → `.sql` |
| `07-query-design.md` | `07-query-design-G04.sql` | Extension `.md` → `.sql`; added `-G04` suffix |

## 5. SKILL.md Pipeline Updates

| Section | v1 | v2 |
|---|---|---|
| Behavior | No model-specific instructions | **DeepSeek Optimization** subsection added |
| Step 5 spec | DDL Schema (`.md`) | DDL Schema, Pure SQL (`.sql`) |
| Step 6 spec | Constraints and Indexes (`.md`) | Sample Data, Pure SQL INSERT (`.sql`) |
| Step 7 spec | Query Design (`.md` with parameterized section) | Query Design, Pure SQL (`.sql` with per-query `DECLARE` params) |

---

*Generated 2026-06-22 — Group 04*
