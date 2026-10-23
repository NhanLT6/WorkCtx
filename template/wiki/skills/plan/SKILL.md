---
name: plan
description: Use when a new or changed {{PROJECT}} feature request needs an impact assessment and implementation plan before coding.
---

# Plan a feature change

Describe the proposed change against verified current behavior; do not implement the request during analysis.

1. Read `wiki/README.md` and `wiki/templates/plan.md`. Capture the request as stated, its source, and any
   interpretation separately. Ask for missing details that would materially change the assessment.
2. Search relevant `wiki/features/` pages and their links. Verify the specific current behavior against the working
   branch's code and tests; record the revision checked. Investigate connected entry points and shared components, not
   the whole repository.
3. Map affected features, dependencies, integrations, data flows, permissions, regressions, and acceptance checks. For
   each important claim, cite a feature page or repository-relative code path. Label assumptions and unverified leads.
4. When a durable record is useful, write `wiki/tickets/<ID or slug>/plan.md` from the template, with its frontmatter
   (use a short kebab-case slug when there is no ticket); keep `features`, `status` and `updated` current. Keep request, current behavior, proposed behavior, risks,
   questions, and verification distinct. A quick user question may need only an in-chat assessment.
   Save ticket assets (sql, scripts, screenshots, field maps) in the same folder and link them relatively. Keep the
   `## Checkpoint` section current; it replaces any separate ticket state file.
5. State the master/release status of affected existing behavior only when checked. A proposed change is not available
   merely because its ticket or research note describes it. End with decisions needed before implementation.

Do not update feature pages as shipped behavior until implementation is verified; use `learn` then. One plan per
request; link feature pages instead of restating them.
