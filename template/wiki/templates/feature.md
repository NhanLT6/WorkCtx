---
type: feature
area: <area>              # file name prefix; areas are listed in README.md "Page naming"
status: partial           # checked | partial | needs-recheck | research
code_checked: <commit-or-branch> <YYYY-MM-DD>     # omit if not checked against code
master_baseline: <{{MASTER_REF}} commit> <YYYY-MM-DD>     # omit if not compared
availability: unknown     # confirmed-by vX.Y.Z | not-on-master | mixed | unknown
first_release: unknown    # vX.Y.Z | unknown | none (not released)
related: ["[[other-feature]]"]     # feature page names, no .md
tickets: ["[[tickets/{{TICKET_EXAMPLE}}/plan]]"]     # plans that list this page in `features`, plus plan links in the body
note: "<optional short nuance that does not fit an enum>"
---
# <Feature name>

<!-- One feature only. Link other features instead of describing them. See "One feature per page" in README.md. -->

## Purpose and users

<What this feature lets someone do and who uses it.>

## Current behavior

<Entry point, important steps, outcomes, and notable limits. Separate observed behavior from assumptions.>

## Implementation map

| Area                                   | Role           | Evidence                                |
|----------------------------------------|----------------|-----------------------------------------|
| <UI, API, service, library, job, data> | <What it does> | <repo-relative path and symbol or line> |

## Dependencies and effects

<Other features, integrations, data changes, notifications, background work, permissions, or shared components affected.
Link to their pages if present.>

## Checks and known issues

<Relevant tests or manual checks; known limits supported by evidence.>

## Open questions

<What is still unverified. Remove items as they are resolved.>

## History and sources

<Links to related ticket plans (`wiki/tickets/<ID>/plan.md`) and code evidence. Include any decision context needed without depending on another folder.>
