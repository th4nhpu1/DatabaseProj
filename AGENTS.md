# AGENTS.md — Campus Space Management System

Database systems project for the Campus Space Management System. Treat this as a real deliverable: correctness, consistency, and safe execution matter as much as completeness.

## Recurring context

- Root directory: <!-- YOUR ROOT DIRECTORY -->
- Run `ls -la` (and `ls -la req/`, `ls -la outputs/`) at the start of every session to detect what already exists before assuming anything — including whether a prior partial run left outputs behind.
- Do not assume the requirement document's filename or location. Check `req/`, the project root, and anything the user attaches.

## Skills

- The active skill for this repo is **`db-design-pipeline`** (see `SKILL.md`), which turns the Campus Space Management System requirement into the full Phase 1 design package (business analysis → ERD → logical design → validation → DDL → sample data → queries → execution verification).
- **SKILL.md owns the step-by-step pipeline, output paths, and file contents.** This file does not restate or fork that — if the two ever disagree, SKILL.md wins for pipeline mechanics, and the discrepancy should be reported to the user rather than silently resolved.
- Invoke the skill whenever the user asks to generate, continue, or fix any part of the design package for the Campus Space Management System.

## DBMS

Use Microsoft SQL Server unless the user specifies another DBMS (matches SKILL.md's project convention #2).

## Execution environment for Step 8 (verification)

- Before running Step 8, check what's actually available: a running/containerized SQL Server instance, `sqlcmd`, Docker, or none of the above.
- If a real instance is reachable, execute the DDL, sample data, and queries against it as SKILL.md requires.
- If no instance is reachable, fall back to a syntax/lint check and say so explicitly in the output — do not report the pipeline as "done" per SKILL.md's Definition of Done if execution genuinely couldn't be verified. State what was and wasn't verified.

## Handling ambiguity

(Referenced by SKILL.md's "Output quality rules" — defined here since it applies across every step.)

- Never silently invent a business rule, cardinality, constraint, or default value that isn't stated or clearly implied by the requirement input.
- When something is genuinely ambiguous:
  1. Make the smallest reasonable assumption needed to keep moving.
  2. Record it explicitly in the relevant output file's assumptions section, tagged Minor or Structural per SKILL.md Step 1.
  3. If the ambiguity is Structural (i.e., it would change the schema, a trigger's behavior, or a query's correctness depending on how it's resolved), surface it to the user directly in your chat response, not just buried in the doc — don't let the pipeline silently march past a decision that should be the user's call.
- If the PDF and a separate requirement file disagree, state the discrepancy and the assumption used, per SKILL.md's output quality rules — do not average or merge conflicting requirements.

## Handling reruns

(Referenced by SKILL.md's "Output quality rules" — defined here since it applies across every step.)

- Default to updating only the files needed for the requested scope (e.g., "fix the ERD" touches `02-erd-design-G04.md`, not the whole pipeline).
- However, always propagate downstream: if an earlier-step file changes in a way that invalidates a later one (e.g., an entity is added/removed in the ERD after logical design already exists), regenerate or patch every downstream file whose content depended on it, and say which files were touched and why.
- Before declaring a rerun complete, re-check Step 4's traceability matrix and Step 8's verification pass — a change upstream can silently break a trigger, a sample-data insert order, or a query's assumptions even if nobody asked to touch those files.
- If a full regeneration is genuinely needed, confirm scope with the user first rather than assuming — regenerating Steps 5–7 means re-running Step 8 verification too, which is expensive to redo unnecessarily.