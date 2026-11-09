---
name: start
description: Use when starting or returning to a specific {{PROJECT}} ticket and the user wants a brief before implementation.
---

# Start a ticket

Build a short, evidence-backed brief, then stop for the user's decision. This is analysis, not authorization to
implement.

1. Identify the ticket key and request from the user or an authorized, working Jira connection. If neither provides the
   request, state what is missing and stop; do not invent it.
2. On a returning ticket, first read `wiki/tickets/<ID>/plan.md` (frontmatter and Checkpoint) and the folder's other
   files, then inspect the current branch, commits, and uncommitted diff without modifying them. If the work looks
   finished (branch merged into `{{MASTER_REF}}`, or Jira status Done), say so and propose running `learn` instead of
   new work.
3. Find current behavior. Read `wiki/README.md` and related feature pages (frontmatter first) as leads. Then trace the
   code the request touches, from its entry point (page, route, handler) through to data and side effects (flags,
   notifications, events). The wiki is filled only by `learn`, so a missing page means the code is the source. Record
   the revision checked.
4. Walk the user through the current flow end to end before asking for decisions. Use a visual when the flow has
   several steps or actors; for a complex ticket, the `doc` skill can hold it as the ticket doc. Mark unverified parts. Skip this on a returning ticket or when the user says they know the
   feature.
5. Lay the request over the current flow: what changes, where the request disagrees with the code, related code,
   affected features, assumptions, risks, and unresolved questions. Mark inaccessible Jira or Confluence evidence as
   unavailable.
6. Give a plain Markdown brief of at most 25 lines (the walkthrough is separate): request or last known state; what
   changed; related code; unclear points; risks; proposed next step. Cite paths and the revision checked where useful.
7. Stop before code changes. If the user asks for a durable plan, use the `plan` skill after this brief.
