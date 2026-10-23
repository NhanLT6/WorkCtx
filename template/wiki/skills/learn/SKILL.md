---
name: learn
description: Use when a {{PROJECT}} feature or ticket has been implemented and verified, and the local feature wiki needs to reflect it.
---

# Learn from completed work

Update only the feature knowledge touched by the completed change. The wiki records observed behavior, not a ticket's
promised behavior.

1. Read `wiki/README.md`; identify the completed behavior from the user's request, relevant diff or commit, and tests or
   other verification. If completion is unverified, report the gap before recording it as current behavior.
2. Search related pages in `wiki/features/` and follow their feature links. Check the changed behavior and connected
   effects against current code. Do not scan the whole repository.
3. Follow "One feature per page" in `wiki/README.md`: put each fact in the page of the feature it belongs to, create a
   new page when no page fits, and link instead of copying. Never widen a page or its file name to cover a second
   feature. Name new pages by "Page naming" in `wiki/README.md`. Update existing pages or create a focused page from `wiki/templates/feature.md`. Record purpose, current behavior,
   implementation map, dependencies, checks, open questions, repository-relative evidence paths, and the checked
   revision/date. Update the page's frontmatter too (`status`, `code_checked`, `availability`, `related`, `tickets`).
   Update `wiki/features/index.md` for a new page.
4. For availability claims, compare the specific behavior with `{{MASTER_REF}}` and a release merge commit. Use
   “confirmed by” when present there; claim a first release only after checking the previous release lacks it. Mark
   branch-only or proposed behavior separately.
5. Link `wiki/tickets/<ID>/plan.md` when one exists and set its frontmatter `status: done` and `updated`. Report pages changed and
   any unverified claims left open.

Keep the wiki self-contained; do not link to research folders outside it or copy secrets or customer data into it.
