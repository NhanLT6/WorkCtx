# {{PROJECT}} feature wiki

A local, incremental map of how {{PROJECT}} features currently work and what they depend on. It supports plans for new
requests and changes to existing features. It is personal and excluded from git.

## Start here

- [Feature index](features/index.md): pages added after a real feature investigation.
- [Feature page template](templates/feature.md).
- [Plan template](templates/plan.md).
- Ticket folders: `tickets/<ID>/plan.md`, one folder per ticket (see "Ticket folders").

## Working method

1. Start with the feature or request at hand. Search this wiki and relevant code. Pages cover researched areas, not
   the whole project.
2. Check code before recording present behavior. A page may carry earlier research or a proposal that was never
   shipped; its `status` and `availability` say how far it was verified.
3. Expand a feature page only for behavior actually investigated. Cite repository paths and the Git revision checked.
   Keep note-sourced leads explicitly unverified until checked.
4. For a new request, write the requested behavior separately from current behavior. Use a plan to identify related
   feature pages, code areas, integration points, possible regressions, and questions to resolve.
5. When implementation changes behavior, verify the result and update the affected feature pages. Link the plan for the
   decision history.

Feature pages describe the product as observed. Plans describe a proposed change at a point in time.

## One feature per page

Each feature page covers one feature and stands alone. A reader should understand it without opening another page.

- Do not combine features in one page or file name. A name with "and" is a sign of two features; split it.
- A shared component or rule gets its own page. Other pages link to it in one sentence; do not copy its details.
- Cross-feature effects go under "Dependencies and effects" as links, not as sections about the other feature.
- Ticket-specific decisions go in the ticket's `plan.md`, not a feature page. A feature page may link to the plan.
- Before adding a section, ask: is this about this page's feature? If not, put it in the right page and link it.

## Ticket folders

Each ticket has one folder, `tickets/<ID>/` (a short kebab-case slug when there is no ticket; rename it to the ID if a
ticket is created later). It holds `plan.md` and every file kept for that ticket: sql, ps1 or js scripts, screenshots,
documents. Ticket files never go elsewhere in the wiki. `tickets/misc/` is only for files that span several tickets.

`## Checkpoint` in the plan keeps the current state of the work: updated, doing, decisions, waiting on, next step.

## Frontmatter

Every feature page and plan starts with frontmatter. It is metadata for agents and Obsidian; people read the body.
Agents read and update it first, and keep every wikilink resolvable: `[[name]]` is `features/name.md`,
`[[tickets/X/plan]]` is `tickets/X/plan.md`. Body links stay relative markdown links.

Feature page (`features/*.md`, not `index.md`):

- `type`: `feature`.
- `area`: the file name prefix (see "Page naming").
- `status`: `checked`, `partial`, `needs-recheck` or `research`.
- `code_checked`: `<commit-or-branch> <YYYY-MM-DD>`. Omit when not checked against code.
- `master_baseline`: `<commit> <YYYY-MM-DD>`. Omit when not compared.
- `availability`: `confirmed-by vX.Y.Z`, `not-on-master`, `mixed` or `unknown`.
- `first_release`: `vX.Y.Z`, `unknown` or `none` (not released).
- `related`: wikilinks to other feature pages.
- `tickets`: wikilinks to plans that list the page in `features`, plus plans linked in the body.
- `note`: optional short nuance that does not fit an enum.

Plan (`tickets/<ID>/plan.md`):

- `type`: `plan`.
- `ticket`: the ID or slug. `title`: short title.
- `status`: `draft`, `approved`, `in-progress`, `implemented` or `done`.
- `created`, `updated`: dates.
- `features`: wikilinks to related feature pages.
- `jira`: link to the ticket.

`features` in a plan and `tickets` on a feature page must agree both ways. `features/index.md` keeps a table for readers
without Obsidian; the frontmatter is the source of truth.

## Page naming

File names start with the area, then the feature, so related pages sort together, for example `billing-invoices.md`,
`integration-<system>.md`, `notification-<channel>.md`. Areas in use:

- <add each area prefix here when the first page for it is created>

Add a new area prefix only when no existing one fits, and list it here. Lowercase, words joined by `-`.

## Version and master convention

`master_baseline` is the locally available `{{MASTER_REF}}` snapshot, with its commit and check date.
`availability: confirmed-by vX.Y.Z` means the cited capability is visible in that release merge commit; it does not
claim this was the first release. Keep `first_release: unknown` until the introducing behavior and release boundary have
both been traced. Use `not-on-master` when the capability is absent from the baseline, and `mixed` when a page covers
both released behavior and later proposals. A file's presence alone proves only the entry point, so name the specific
behavior checked in `note`. Recheck availability when the master reference moves.

## Evidence convention

Use relative links between wiki pages and repository-root-relative paths for code. Record the commit or branch and date
of code checks in `code_checked`. If a claim comes only from a note or a ticket, label it unverified until the code or
running behavior confirms it. Do not copy secrets, customer data, or full source files into the wiki.

The wiki has no git history. Before moving or rewriting many pages, copy the wiki to a temporary folder first.
