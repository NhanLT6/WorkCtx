# WorkCtx — Spec v3

> Updated: 2026-09-17
> Replaces v1 (local Express app) and v2 (6 manual skills). See "Changes" at the end.

## What This Is

A **convention, not an app**: a git-tracked folder of markdown, user-level rules for AI agents, one core skill, and a tiny git hook. It helps a developer:

1. **Start or return to a ticket** with a short brief built from Jira, Confluence, code and past sessions, without copy-pasting.
2. **Never lose context when stopping**, without having to remember to "pause".
3. Later, and only if the core proves useful: **build a feature knowledge base** and **produce a daily worklog** for Daybook.

It is a productivity layer on top of the normal way of working. Jira, Confluence, Figma, Rider and the browser stay where they are. All intelligence lives in the AI agent. No server, no UI, no database.

---

## Why Earlier Versions Were Changed

- **v1** required building and maintaining an app; there was no time for that. "View everything in one place" is not achievable (Jira/Confluence/Figma block embedding). The real bottleneck was AI access to data, now solved by MCP.
- **v2** relied on the user calling `pause`/`resume`. Tools that require manual start/stop fail because people forget or skip them. A previous skill (`ac-gap-analysis`) was abandoned for being long, template-heavy, tree-formatted and costly to maintain. v3 is designed against both failure modes.

---

## Decisions

| Topic | Decision |
|---|---|
| Form | Folder + user-level `AGENTS.md` + skills + git hook. No app |
| Primary agent | **Codex** for reading/synthesis. Claude Code for coding work |
| Agent lock-in | Open standards only: markdown, git, MCP, `AGENTS.md`, Agent Skills (`SKILL.md`). Agent-specific data (session transcripts) is optional evidence, never required |
| Install scope | **User level**, not per repo. Agents are opened inside the company code repo (IDE), so WorkCtx must work from any directory |
| Paths | Skills and rules reference the KB by absolute path (`$WORKCTX_HOME`) |
| Jira / Confluence | Atlassian Rovo MCP Server (Jira Cloud), configured **globally** in the agent |
| Start | Automatic from prompt intent + folder check; manual command as fallback |
| Pause | **Lazy pause**: no summary at stop time. State is reconstructed at next start from evidence. Stop events are timestamps only, used for the time log |
| After analysis | Agent **stops with proposal + questions. Never modifies code** in the start flow |
| Ticket analysis skill | `ac-gap-analysis` retired. Its core ("what is undefined") becomes one section of the start output |
| Coding behavior | Adapted Karpathy-inspired principles in user-level `AGENTS.md` (not the plugin, not copied verbatim) |
| History | git. No custom versioning |
| Viewer | Any markdown editor. Obsidian optional later. Links written as `[[page-name]]` |
| Command names | Plain, common English words |
| Time tracking | Reconstructed from events + evidence, rounded to 15 min, human-reviewed. Not a stopwatch |

---

## Principles

1. **Automatic first, manual as fallback.** Never require the user to remember a step.
2. **Stop before code.** Analysis ends with a proposal and questions; the user decides.
3. **Code is ground truth.** Cross-check claims against the repo, not only Confluence.
4. **Don't mirror sources.** Store derived knowledge and links; fetch Jira/Confluence fresh via MCP.
5. **Never invent data.** Unknowns are stated as unknowns; estimated times are marked `estimated`.
6. **Small skills.** Each `SKILL.md` ≤ 40 lines. Output is plain markdown (headings + bullets), no trees, no nested tables. At most one file template (`ticket.md`).
7. **Measure, then expand.** Phase 1+ only if Phase 0 passes its evaluation criteria.

---

## Layout

### KB folder (`$WORKCTX_HOME`, separate local git repo, no remote)

```
work-kb/
  README.md                     ← what this folder is
  tickets/
    T-123/
      ticket.md                 ← frontmatter + last known state
      notes.md                  ← optional manual notes
      <any files>
  worklog/
    events.jsonl                ← append-only start/stop events
  wiki/                         ← Phase 1 only
```

### User-level files (outside any company repo)

| File | Purpose |
|---|---|
| User-level `AGENTS.md` for Codex (expected `~/.codex/AGENTS.md`, **verify**) | WorkCtx rules + coding principles |
| Claude Code user-level `CLAUDE.md` (expected `~/.claude/CLAUDE.md`, **verify**) | Imports / mirrors the same rules |
| `~/.agents/skills/<command>/SKILL.md` | The start skill (Codex user-level skill path, **verify**). Symlink into Claude Code's user-level skills folder |
| `$WORKCTX_HOME/scripts/post-checkout` | Git hook script, linked into each work repo's `.git/hooks/` |

**Never** put WorkCtx rules in a company repo's `AGENTS.md`/`CLAUDE.md` (they would be committed and shared). **Never** set `git config --global core.hooksPath` (it overrides existing repo hooks).

---

## `ticket.md`

```markdown
---
ticket: T-123
label: <short title>
project: <project name>
status: active            # active | paused | done
jira: https://<site>.atlassian.net/browse/T-123
branch: <branch name>
repo: <absolute path to code repo>
links:
  - label: Confluence spec
    url: https://...
---

## Last Known State
Updated: 2026-09-17 11:45 (source: start brief)

- Doing: ...
- Decisions: ...
- Tried / dropped: ...
- Waiting on: ...
- Next step: ...
```

`Last Known State` is overwritten by each start brief. History is in git.

---

## Core Skill: `start` (working name, see Handoff)

### Triggering

1. **Automatic:** user-level `AGENTS.md` rule: *when the user mentions a ticket ID with intent to work on it (start, continue, pick up, look at, fix — in English or Vietnamese), run the start skill before anything else.*
2. **Manual fallback:** invoke the skill explicitly by name.

Automatic intent detection is not guaranteed; the manual command must always work.

### Flow

```
detect ticket ID
  │
  ├─ tickets/<ID>/ missing  → NEW
  │     1. Fetch ticket + linked Confluence via MCP
  │     2. Find related code in current repo
  │     3. Create tickets/<ID>/ticket.md
  │
  └─ tickets/<ID>/ exists   → RETURNING
        1. Read ticket.md + notes.md
        2. Gather evidence since last update (see below)
        3. Fetch Jira changes since last update via MCP
  │
append {"event":"start"} to events.jsonl (auto-stop previous active ticket)
write Last Known State to ticket.md
output brief → STOP, wait for user
```

### Evidence for RETURNING (lazy pause)

| Source | Gives | Required |
|---|---|---|
| git: branch, commits, **uncommitted diff** | What changed in code | Yes |
| Jira via MCP: comments, status changes | What changed outside | Yes |
| `notes.md` | Manual notes | If present |
| Agent session transcripts for this ticket (Codex / Claude Code local session files, **paths to verify**) | Decisions, dead ends, open questions not in git | Optional; skip silently if unreadable |

### Output (≤ 25 lines, plain markdown)

- **What the ticket asks** (NEW) / **Where I left off** + **What changed** (RETURNING)
- **Related code** — files and what they currently do
- **Unclear / assumptions** — what is undefined or guessed
- **Risks** — side effects on existing features, known issues
- **Proposed next step** — then stop

Never modify code in this flow.

### Manual stop (optional)

A manual stop command is **not required**. If kept, it only appends a stop event and optionally one line to `notes.md`. Decide during Phase 0 whether it is worth keeping.

---

## Events & Automatic Triggers

### `worklog/events.jsonl`

```json
{"ts":"2026-09-17T09:10:00+07:00","event":"start","ticket":"T-123","source":"agent"}
{"ts":"2026-09-17T11:45:00+07:00","event":"start","ticket":"T-150","source":"git-checkout"}
{"ts":"2026-09-17T17:40:00+07:00","event":"stop","ticket":"T-150","source":"sleep"}
```

A `start` implies `stop` of the previously active ticket. Events are only used for the time log (Phase 2); context never depends on them.

### Triggers

| Trigger | Mechanism | Reliability | Phase |
|---|---|---|---|
| Start from prompt | `AGENTS.md` rule + skill | Fairly high | 0 |
| Switch ticket | git `post-checkout` hook: branch name contains ticket ID → `start` event | Very high | 0 |
| Sleep / shutdown | systemd-logind D-Bus (`PrepareForSleep`, `PrepareForShutdown`) via user service → `stop` event | High | 2 |
| Screen lock / idle | Desktop environment lock/idle signal → `stop` event | Medium, DE-specific | 2 |
| Close IDE / terminal | No reliable generic hook | Low | **Dropped** |

`post-checkout` hook requirements: act only on branch checkouts (3rd arg = `1`); extract ticket ID with the configured pattern; if none found, do nothing; never fail the checkout (always exit 0); ≤ 15 lines.

Known gap: work outside agents and outside ticket branches (e.g. reading code on `master`) leaves no trace. Briefs get thinner, not wrong.

---

## User-level `AGENTS.md` Must Cover

Keep it short (target ≤ 60 lines).

**WorkCtx**
- `$WORKCTX_HOME` path and layout
- Ticket ID pattern; branch naming convention
- Auto-start rule (see Triggering)
- Stop-before-code rule for the start flow
- Timezone for timestamps

**Coding principles** (adapted from the community CLAUDE.md inspired by Karpathy's observations; rewrite for this stack, don't copy verbatim)
- Think before coding: state assumptions, ask when unclear
- Simplicity first: minimum code for the request, no speculative abstractions
- Surgical changes: touch only what the task needs, match existing style
- Goal-driven: define how success is verified before implementing
- Stack-specific rules: **ask the user** (e.g. generated files, DBML, Web Forms designer files)

---

## Phases

### Phase 0 — Core loop (build cost: hours)
> Principle: check the employer's policy on local data and AI agents before installing.

- [ ] Configure Rovo MCP globally in Codex; verify it reads a real ticket
- [ ] Create `$WORKCTX_HOME` repo + README
- [ ] User-level `AGENTS.md` (+ Claude Code equivalent)
- [ ] `start` skill
- [ ] `post-checkout` hook script + install instructions per repo
- [ ] Use for 2–3 weeks on real tickets

### Phase 0 evaluation (decide before Phase 1)
1. Was `start` used (auto or manual) for most tickets, instead of ad-hoc prompts?
2. Did auto-start trigger reliably from normal prompts?
3. On returning tickets, did the brief contain useful information that git + Jira alone would not give (e.g. from transcripts/notes)?

- 1 = no → simplify the skill or drop WorkCtx.
- 3 = no → drop ticket folders and state; keep only `start` as a stateless analysis skill. This is an acceptable outcome.
- All yes → Phase 1.

### Phase 1 — Knowledge base (only if Phase 0 passes)
- `learn`: finished ticket → create/update `wiki/features/*.md`, with sources for every claim
- `impact`: new ticket → related wiki pages + code cross-check → affected features, conflicts, known issues
- `review`: wiki health check (missing sources, contradictions, stale pages, broken links)
- Prefer triggering `learn` automatically (e.g. ticket moves to Done in Jira, noticed at next start) over manual calls
- Note: wiki value is near zero for the first months; do not start it early

### Phase 2 — Daily worklog
- `daily` skill: events + git + Jira + file changes → `worklog/<date>.md` draft → human review → `worklog/<date>.csv`
- Sleep/shutdown/lock watcher (systemd user service)
- Intervals not backed by events are marked `estimated`; meetings and invisible work added manually during review
- Daybook CSV: `project`, `task` (`<ID> <label>`), `date` (`YYYY-MM-DD`), `duration` (**minutes, multiple of 15**), `notes` (1–2 generic sentences, no customer data)
- Daybook change: optional `source_id` column (e.g. `workctx:2026-09-17:T-123`); import upserts on existing `source_id`

### Phase 3 — Tooling (only if real pain remains)
- Open all ticket links in one browser window
- Obsidian as KB viewer
- Direct push to Daybook API
- Calendar via MCP as meeting evidence
- Any UI

---

## Implementation Handoff (for the implementing agent)

**Read this section before doing anything.**

### Prerequisite status

| Item | Status | Owner |
|---|---|---|
| Rovo MCP configured globally in Codex and verified on a real ticket | ⬜ Not done | Human |
| Implementing agent may read work repos, Jira and Confluence | ⬜ Ask | Human |

### Required inputs

| Input | Used in | Value |
|---|---|---|
| Command name for the start skill | Skill folder, `AGENTS.md` | `TBD` (working name `start`; candidates: `start`, `ctx`) |
| `$WORKCTX_HOME` location | Everything | `TBD` |
| Code repo path(s) to install the hook in | Hook install | `TBD` |
| Ticket ID pattern (e.g. `T-123`, `ABC-123`) | Hook, `AGENTS.md` | `TBD` |
| Branch naming convention | Hook | `TBD` |
| Jira site URL | `ticket.md` | `TBD` |
| Timezone | Events | `+07:00` (confirm) |
| Stack-specific coding rules | `AGENTS.md` | `TBD` (ask) |
| Keep an optional manual stop command? | Skills | `TBD` (default: no) |

### To verify against current docs (do not assume)

- Codex user-level `AGENTS.md` location
- Codex user-level skill discovery path and `SKILL.md` frontmatter
- Claude Code user-level `CLAUDE.md` and skills locations
- Codex and Claude Code local session transcript locations and format
- How to configure a remote MCP server globally in Codex

### Instructions

1. **Before starting, ask the human for every `TBD` value and every ⬜ / Unknown prerequisite.** Do not guess. If the human wants to proceed without some, use visible placeholders like `<TODO: ticket ID pattern>` and list them all at the end.
2. If "Implementing agent may read work repos, Jira and Confluence" is not confirmed: build only files, skill, hook and rules. Do not read company repos, Jira or Confluence.
3. **Scope is Phase 0 only.** Do not implement `learn`, `impact`, `review`, `daily` or any watcher service.
4. Respect Principle 6 (skill ≤ 40 lines, plain markdown output). Keep the hook ≤ 15 lines and always exit 0.
5. Do not modify any company repo except adding the hook file to `.git/hooks/` (untracked) with the human's approval. Never set a global hooksPath.
6. `$WORKCTX_HOME` is a separate local git repo; never add a remote.
7. After finishing, tell the human to test **in Codex** inside a work repo: (a) type a natural prompt about a new ticket, (b) switch to a ticket branch and check `events.jsonl`, (c) come back to the ticket in a new session and check the RETURNING brief.
8. When a prerequisite or input is resolved, update the tables in this section.

---

## Non-Goals

- No server, UI or database (Phases 0–2)
- No embedding of Jira / Confluence / Figma
- No bundled AI; no dependency on agent-specific features
- No code changes in the start flow
- No automatic submission of time logs
- No team sharing

## Known Limitations

- Auto-start depends on the agent following `AGENTS.md`; not 100% reliable.
- Transcript formats are agent-specific and may change; treated as optional.
- Work leaving no trace (meetings, reading code on `master`) is invisible.
- Output varies between models; short templates limit drift.
- Third-party skills can carry prompt injection; use only self-written skills.

---

## Changes

| v1 | v2 | v3 |
|---|---|---|
| Express app, 5 views | Folder + 6 manual skills | Folder + 1 core skill + git hook |
| Per-folder config | Repo-level `AGENTS.md` | **User-level** rules, absolute paths |
| Park / Reconstruct buttons | Manual `pause` / `resume` | **Auto start**, **lazy pause** |
| `context.md` prepended | `ticket.md` state on pause | State rebuilt at start from git + Jira + transcripts |
| — | Wiki in Phase 1 | Wiki gated by Phase 0 evaluation |
| — | Daily in Phase 2 | Daily + sleep/lock watcher in Phase 2 |
| — | — | `ac-gap-analysis` retired; Karpathy-inspired coding principles adopted |
| — | — | Stop before code; skill size limits |
