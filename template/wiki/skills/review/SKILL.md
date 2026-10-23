---
name: review
description: Use when checking the {{PROJECT}} local feature wiki for stale claims, missing evidence, contradictions, or broken links.
---

# Review wiki health

Audit the wiki as a knowledge source; a ticket, proposal, or file's presence is not proof of shipped behavior.

1. Read `wiki/README.md`, the feature index, and the pages in scope. Resolve wiki links and
   repository-root-relative evidence paths; flag broken targets and pages missing from indexes. Also check each
   `wiki/tickets/*/plan.md`: frontmatter `status` is valid, `features` links resolve, and ticket assets sit inside
   their ticket folder. On every feature page, check the frontmatter: required keys present, enum values valid,
   wikilinks resolve, and `tickets` agrees with the plans' `features` both ways.
2. Flag pages that cover more than one feature (see "One feature per page" in `wiki/README.md`), including file names
   joined with "and", and propose the split. Flag file names that break
   "Page naming" in `wiki/README.md`. Check page status, code revision/date, master baseline, availability, and first-release claims. Distinguish observed
   behavior from research leads, proposals, and branch-only work.
3. For stale or conflicting claims, check the specific behavior in cited code and relevant Git revisions. Compare
   release boundaries before asserting a first version. Avoid a full repository scan when a focused check suffices.
4. Report findings by page and claim, with evidence, severity, and a recommended correction. Explicitly say when a claim
   cannot be verified with available sources.
5. Keep the review read-only unless the user asks to repair the pages; then make only evidence-backed corrections and
   recheck links.

Do not make the wiki depend on folders outside it.
