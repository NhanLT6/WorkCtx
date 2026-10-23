---
name: start
description: Use when starting or returning to a specific {{PROJECT}} ticket and the user wants a brief before implementation.
---

# Start a ticket

Build a short, evidence-backed brief, then stop for the user's decision. This is analysis, not authorization to
implement.

1. Identify the ticket key and request from the user or an authorized, working Jira connection. If neither provides the
   request, state what is missing and stop; do not invent it.
2. Read `wiki/README.md`, then search related feature pages (frontmatter first) and check only relevant current code and tests. On a
   returning ticket, first read `wiki/tickets/<ID>/plan.md` (frontmatter and Checkpoint) and the folder's other files,
   then inspect the current branch, commits, and uncommitted diff without modifying them.
   If the work looks finished (branch merged into `{{MASTER_REF}}`, or Jira status Done), say so in the brief and
   propose running `learn` instead of new work.
3. Separate confirmed current behavior from the requested change. State related code, affected features, assumptions,
   risks, and unresolved questions. Mark inaccessible Jira or Confluence evidence as unavailable.
4. Give a plain Markdown brief of at most 25 lines: request or last known state; what changed; related code; unclear
   points; risks; proposed next step. Cite paths and the revision checked where useful.
5. Stop before code changes. If the user asks for a durable plan, use the `plan` skill after this brief.
