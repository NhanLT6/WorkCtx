# Local {{PROJECT}} feature knowledge

This file and `wiki/` are local to this checkout. Keep them out of commits.

Skills in `.agents/skills/` (Codex) and `.claude/skills/` (Claude Code) point to `wiki/skills/`:

- `start`: brief when starting or returning to a ticket. Ends with a proposal and questions; never modifies code.
- `plan`: impact assessment and implementation plan for a new or changed feature, before coding.
- `learn`: update feature pages after a change is implemented and verified.
- `review`: wiki health audit.

`doc` is a standalone skill linked at user level: the HTML doc for a complex ticket, saved in its ticket folder, or an
explainer of a technique the user asks about. Simple tickets get no doc.

When working on a feature or evaluating a feature request:

1. Search `wiki/features/` for the feature and connected features. Read the frontmatter first, then the body. Treat
   pages as leads; verify relevant claims against the current code.
2. Each ticket gets one folder, `wiki/tickets/<ID or slug>/`, holding `plan.md` and every file kept for it (sql,
   scripts, screenshots, documents). Never save ticket files anywhere else.
3. For a new request, describe current behavior, requested behavior, affected paths, dependencies, risks and open
   questions. Use `wiki/templates/plan.md` when a written plan is useful. Keep its `## Checkpoint` current.
4. Recheck a claim against code before treating it as current behavior. Create pages from `wiki/templates/feature.md`,
   recording code evidence and the revision checked. Mark uncertainty and proposed behavior explicitly.
5. Update linked feature pages only after code changes are verified. Avoid full repository scans and speculative pages.
6. For version claims, compare the specific behavior with `{{MASTER_REF}}` and a release merge commit. Name a first
   release only after checking the previous release lacks it.

Read `wiki/README.md` for the page conventions. User instructions and current code take precedence over wiki notes.
