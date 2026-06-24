# Agent Improvement Process
# Project: Campus Space Management System (CS486)

## Overview
During the development of our autonomous database design agent, we evaluated the model's outputs at each of the seven required phases. We utilized a lightweight LLM (Deepseek v4 flash) for rapid generation. While the agent correctly understood standard database paradigms and syntax, our evaluation revealed consistent issues with "prompt amnesia," where the model failed to retain strict business constraints across long context windows.

To resolve this, we iteratively improved the agent's SKILL.md instructions by implementing explicit guardrails, positive constraints, and forced loop-back evaluations.

## Evaluation and Refinement by Phase
### Phase 1 & 2: Conceptual Design and ERD
Evaluation: The agent successfully normalized the booking lifecycle but forced a flawed assumption: a mandatory 1:1 relationship between BookingRequest and BookingApproval. This would break the system for standard rooms that might not require manual approval. It also failed to explicitly map relationship lines for auditing (e.g., who performed a check-in).

Improvement: We updated SKILL.md to explicitly demand the accommodation of conditional approval workflows. We also added positive constraints requiring the agent to draw distinct Mermaid relationship lines for audit trails and to detail structural logic for handling overlapping Pending requests.

### Phase 3 & 4: Logical Schema and Validation
Evaluation: The logical schema correctly applied surrogate keys and audit columns. However, the agent's Phase 4 Validation completely ignored a critical project directive to "loop back and fix" structural gaps. It blindly validated its own flawed 1:1 approval assumption and ignored the complexities of date-range overlap constraints for pending requests.

Improvement: We introduced CRITICAL CHECK flags into the Step 4 prompt. We mandated that the agent explicitly verify its support for optional approvals and pending overlaps, forcing a failure and a loop-back to Step 1 if the mandatory 1:1 approval flaw was detected.

### Phase 5: Database Implementation (DDL)
Evaluation: The SQL syntax was highly accurate, but the agent took lazy shortcuts in its triggers. For instance, to populate the StatusHistory tables, it hardcoded the ChangedBy user as the original requester, destroying the system's auditability. It also failed to write the AFTER UPDATE triggers required to populate its own ModifiedAt columns.

Improvement: We refined the Step 5 instructions to strictly forbid using triggers for history insertion unless application context (like SESSION_CONTEXT()) was utilized. We also explicitly mandated the inclusion of AFTER UPDATE triggers for modified timestamps and enforced non-destructive database versioning (_v2).

### Phase 6 & 7: Sample Data and Queries
Evaluation: The agent generated syntactically correct data but violated chronological integrity by inserting physical check-ins for future dates. Crucially, it inserted records directly into their final state (e.g., Completed), bypassing the state machine and leaving the history tables empty. Consequently, time-relative queries in Phase 7 returned empty result sets, and the agent hardcoded magic numbers (BookingID = 1) instead of parameterizing its SQL.

Improvement: We injected strict chronological constraints into the Step 6 prompt, requiring sequential UPDATE statements to simulate real-world lifecycles and populate history triggers. For Step 7, we forbade magic numbers, required DECLARE parameters to simulate application inputs, and strictly mandated that any query returning zero rows must trigger a rollback to Step 6 to fix the sample data.