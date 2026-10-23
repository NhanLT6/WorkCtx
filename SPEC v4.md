# WorkCtx: Spec v4

> Updated: 2026-10-22
> Replaces v3 (archived in `archive/`). Written from three weeks of real use on one project. See "Changes from v3".

## What this is

A convention, not an app: a local markdown wiki per code repo, four skills shared by Codex and Claude Code, one
optional Claude Code hook, and an install script. It helps a developer:

1. Start or return to a ticket with a short brief built from code, Jira and earlier notes.
2. Plan a change against how features really work today, before writing code.
3. Keep a feature knowledge base that grows from finished tickets.
4. Keep every file made for a ticket (plan, SQL, scripts, screenshots, documents) in one place.

The wiki is personal. It is not shared with the team and not committed to the code repo.

## Repo contents

```
WorkCtx/
  SPEC v4.md            this file
  install.ps1           installs or refreshes the template in a code repo
  template/
    AGENTS.md           repo-local agent rules (Codex reads it; CLAUDE.md imports it)
    wiki/               skeleton copied to <repo>/wiki/
  archive/              earlier specs and the v1 mockup
```

WorkCtx holds only the generic framework. Never commit project data (feature pages, tickets, company names, URLs) here.
Check the employer's policy on local data and AI agents before installing.

## Layout in a code repo

```
<repo>/
  AGENTS.md                         local rules, excluded from git
  CLAUDE.md                         first line: Local wiki and skill rules: @AGENTS.md
  .agents/skills/<skill>            junction to wiki/skills/<skill> (Codex)
  .claude/skills/<skill>            junction to wiki/skills/<skill> (Claude Code)
  .claude/settings.local.json       registers the hook
  wiki/
    README.md                       conventions: one feature per page, naming, evidence, frontmatter
    features/<area>-<feature>.md    one feature per page
    features/index.md               table for agents; frontmatter is the source of truth
    tickets/<ID or slug>/plan.md    plan and checkpoint for one ticket
    tickets/<ID or slug>/*          every other file kept for that ticket
    tickets/misc/                   only files that span several tickets
    templates/feature.md, plan.md
    skills/{start,plan,learn,review}/SKILL.md
    hooks/wiki_trigger.py
    features.base, tickets.base     Obsidian Bases views
    .obsidian/                      vault settings
```

### Ticket folders

- One folder per ticket, named by ticket ID. Work without a ticket uses a short kebab-case slug; rename the folder to
  the ID if a ticket is created later.
- The folder holds `plan.md` and anything else worth keeping for that ticket. Ticket files never go elsewhere.
- `plan.md` has a `## Checkpoint` section (Updated, Doing, Decisions, Waiting on, Next step). It replaces the separate
  `ticket.md` state file from v3.

Why not a flat `plans/` folder like many plan skills use: those skills treat a plan as a one-off document per task,
with no notion of a ticket, so a dated flat list is enough. Here the unit of work is the ticket, and a ticket collects
many files besides the plan. A folder per ticket keeps them together and keeps links short.

### Frontmatter

Frontmatter is metadata for agents and Obsidian. People read the body. Agents read and update frontmatter first.

Feature page:

```yaml
type: feature
area: billing               # file name prefix
status: checked             # checked | partial | needs-recheck | research
code_checked: <commit-or-branch> <YYYY-MM-DD>
master_baseline: <commit> <YYYY-MM-DD>
availability: not-on-master # confirmed-by vX.Y.Z | not-on-master | mixed | unknown
first_release: unknown      # vX.Y.Z | unknown | none (not released)
related: ["[[other-feature]]"]
tickets: ["[[tickets/ABC-123/plan]]"]
note: "<short nuance that does not fit an enum>"
```

Plan:

```yaml
type: plan
ticket: ABC-123             # or slug
title: <short title>
status: draft               # draft | approved | in-progress | implemented | done
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
features: ["[[feature-page]]"]
jira: <url>
```

Links in frontmatter are wikilinks so Obsidian draws them in the graph. Links in the body stay relative markdown
links so they also work in the IDE and on any markdown viewer. `features` in a plan and `tickets` in a feature page
must agree; `review` checks both directions.

## Skills

One source in `wiki/skills/`, linked into both agents. No agent-specific copies: `SKILL.md` is an open format both
agents read. Each skill stays at or under 40 lines.

| Skill | When | Writes |
|---|---|---|
| `start` | Starting or returning to a ticket | Nothing. Brief of at most 25 lines, then stops before code. Suggests `learn` if the ticket looks done |
| `plan` | New or changed feature needs an impact assessment and plan | `tickets/<ID>/plan.md`, assets in the same folder |
| `learn` | Change implemented and verified | Feature pages and their frontmatter; plan status `done` |
| `review` | Wiki health | Report only, unless asked to fix |

### Triggering

- Codex: `AGENTS.md` lists the skills and when to use them.
- Claude Code: `CLAUDE.md` imports `AGENTS.md`. The hook adds a reminder the first time a ticket ID appears in a
  session; Claude judges whether the intent is start, plan, learn or nothing.
- Manual call by skill name always works.

## Install

```powershell
./install.ps1 -RepoPath E:\repos\MyApp -Project MyApp -TicketPattern '\bABC-\d+\b' `
              -TicketExample ABC-123 -JiraBaseUrl https://myco.atlassian.net/browse
```

- Copies `template/wiki` when `wiki/` is missing and fills the placeholders. With `-Update`, refreshes only skills,
  templates and the hook; feature pages and tickets are never touched.
- Creates `AGENTS.md`, and adds the import line to `CLAUDE.md`. When `CLAUDE.md` is tracked by git, the line goes to
  `CLAUDE.local.md` instead, so no tracked file is edited.
- Creates the skill junctions in `.claude/skills` and `.agents/skills`. A real folder in the way is reported, not
  deleted.
- Adds ignore rules to `.git/info/exclude`, never to the tracked `.gitignore`.
- Registers the hook only when `-TicketPattern` is given. Projects without tickets skip it and call skills by name.

Improving a skill: edit it in the project where you found the problem, copy the change back to
`template/wiki/skills/`, replace project names with placeholders, commit WorkCtx, then run `install.ps1 -Update` in
other projects.

## GUI: Obsidian (optional)

Open `<repo>/wiki` as an Obsidian vault. The template ships the settings.

- Graph view and local graph: how features and tickets connect. Click a node to open the page.
- Backlinks panel: which pages and tickets point to the current page.
- Bases (core plugin, Obsidian 1.9 or later): `features.base` and `tickets.base` build tables from frontmatter, with
  views for pages needing recheck and open tickets. No community plugin needed.
- Settings: relative markdown links, attachments saved next to the current note (a pasted screenshot in a plan lands in
  its ticket folder), `skills/`, `hooks/` and `templates/` hidden from graph and search.

Alternatives and plugins not chosen:

- Dataview: little development in the last year; Bases covers the index use case.
- ExcaliBrain: needs Dataview and Excalidraw; heavy for this size.
- Breadcrumbs: typed relations (for example depends-on). Add later only if `related` proves too coarse.
- Foam (VS Code): works when Obsidian is not installed. `Foam: Show Graph` draws body links (relative markdown
  links included) and the Connections panel lists backlinks. No table views: use `features/index.md` instead of Bases.
  Checked 2026-10-22: the graph also draws the wikilinks in frontmatter (`related`, `tickets`, `features`).

Not yet verified by a person: the Bases filter syntax in the two `.base` files. Open them once and fix if Obsidian
reports an error.

## Principles kept from v3

1. Stop before code in `start`; the user decides.
2. Code is ground truth. Wiki pages are leads until checked; record the revision checked.
3. Do not mirror Jira or Confluence; link them and fetch fresh.
4. Never invent data; unknowns stay marked as unknown.
5. Small skills, plain markdown output.
6. Open formats only: markdown, `AGENTS.md`, `SKILL.md`.

Plus: one feature per page; ticket decisions live in the ticket's `plan.md`.

## Changes from v3

| v3 | v4 | Why |
|---|---|---|
| One user-level KB in `$WORKCTX_HOME` | One wiki per code repo, inside the repo, excluded from git | Agents run inside the repo; relative paths to code just work |
| KB is a local git repo | No git history for the wiki | Personal, by the owner's choice. Back up by other means if needed |
| `tickets/<ID>/ticket.md` with Last Known State | `tickets/<ID>/plan.md` with `## Checkpoint` | The plan already carried the state; one file instead of two |
| Phase 1 gated behind Phase 0 evaluation | `plan`, `learn`, `review` in use | They proved useful before the gate was reached |
| `impact` skill, `impacts/` folder | `plan` skill, ticket folders | Files in it were plans; ticket assets had no home |
| Skills copied per agent | One source, junctions for both agents | Copies drifted: Codex ran outdated skills for weeks |
| Rules only in `AGENTS.md` | `CLAUDE.md` imports `AGENTS.md` | Claude Code does not read `AGENTS.md` by itself |
| Ignore rules in `.gitignore` | `.git/info/exclude` | Editing the tracked `.gitignore` risks committing it |
| `events.jsonl`, `post-checkout` hook | Dropped | Nothing used the events; lazy rebuild from git and the plan is enough |
| Daily worklog for Daybook | Backlog | Still wanted, not started |
| Obsidian as Phase 3 tooling | Optional now, settings shipped | Frontmatter makes graph and tables nearly free |

## Known gaps

- No wiki history: an accidental overwrite cannot be undone. Agents doing big moves must copy the wiki to a temp folder
  first.
- Hook reminders are per session and per ticket. Subagent reports are skipped by text match on their wrapper, which may
  change between Claude Code versions.
- Codex has no hook; triggering relies on it following `AGENTS.md`.
- The `CLAUDE.local.md` fallback is untested on a repo with a tracked `CLAUDE.md`; confirm Claude Code still loads it.
- `features/index.md` is kept by hand next to the frontmatter; `review` should flag drift.
- Ticket folders with no `plan.md` (old research files) are fine but invisible to `tickets.base`.

## Backlog

- Daily worklog for Daybook (low priority, design agreed 2026-10-22, not started):
  - `worklog` skill drafts one day from `git reflog --date=iso` (branch checkouts with ticket IDs replace the dropped
    post-checkout hook), commits, plan `updated` dates and Claude/Codex transcript timestamps. 15-minute rounding,
    guesses marked `estimated`, human review before export. Notes stay generic, no customer data.
  - Step 1: export CSV in Daybook's import format (Id, Date, Project, Task, Duration, Type, Description). Use a stable
    Id such as `workctx:<date>:<ticket>`; Daybook import does `put` by Id, so re-import updates instead of duplicating.
    No Daybook change needed.
  - Step 2 (Daybook repo, separate session): `log_inbox` table on Neon, `POST /api/inbox` with a personal token made in
    Settings, client pulls the inbox into IndexedDB on load and clears it. The skill then posts instead of writing CSV.
    Runs on the Hobby plan with no AI Gateway use; the token stays on the machine, never in the wiki or a repo.
  - Rejected: a folder sync through the File System Access API (one click saved, Chrome/Edge only).
- A link checker script for `review`, if manual checks become slow.
- Breadcrumbs typed relations, if the graph needs edge types.
