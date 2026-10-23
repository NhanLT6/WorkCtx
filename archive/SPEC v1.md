# Work Context Tracker — Build Spec

## What This Is

A local web app that runs as a Node.js server at `localhost:3000`. It helps developers and non-developers maintain work context across tickets, context switches, and time away. It is **not** an AI tool — it is a workspace organizer that **invokes** an external AI agent (Claude Code, Codex, or any configured CLI agent) on demand. All intelligence lives in the agent, not in the app.

---

## Stack

- **Runtime**: Node.js (or Bun)
- **Server**: Express (minimal, ~100 lines)
- **Frontend**: Plain HTML + vanilla JS, no framework
- **Storage**: Local filesystem only, no database
- **AI**: External CLI agent, configurable (not bundled)
- **Auto-start**: Runs as a systemd service (Linux/Fedora) or launchd (macOS) so it starts with the machine — user never manually starts it

---

## Folder Structure

### App itself
```
~/work-context-app/
  server.js           ← Express server
  config.json         ← user config (agent command, workspace root)
  public/
    index.html
    app.js
    style.css
```

### Workspace (user data, separate from app)
```
~/work-contexts/               ← configurable root path
  ABC-123/
    context.md                 ← latest agent-written context, always current
    links.md                   ← external links (label + URL pairs)
    AGENT.md                   ← instructions for the agent, user-written once
    notes.md                   ← free-form user notes
    query.sql                  ← any files user drops in
    screenshot.png
    .versions/                 ← hidden, managed by the app
      context.2025-01-20.md
      context.2025-01-24.md
      query.2025-01-22.sql
      query.2025-01-22.note.txt   ← optional change note for that version
  ABC-124/
    ...
```

---

## Config File

`~/work-context-app/config.json`:

```json
{
  "workspaceRoot": "~/work-contexts",
  "agent": "claude",
  "parkPrompt": "Read all files in this folder. Summarize: what ticket is this, what was in progress, what was the last action, what are the next steps. Write the result into context.md with a timestamp header. Do not overwrite — prepend the new summary above the previous one.",
  "reconstructPrompt": "Read context.md and all files in this folder. Give me a concise re-entry brief: what is this ticket about, where was I, what do I do next."
}
```

The `agent` field is any CLI command available in the user's PATH. The prompts are fully user-editable.

---

## Server API (Express routes)

```
GET  /api/tickets                        → list all ticket folders
POST /api/tickets                        → create new ticket folder { name, jiraUrl? }
GET  /api/tickets/:id/files              → list files in ticket folder (excludes .versions)
GET  /api/tickets/:id/files/:filename    → read file content
POST /api/tickets/:id/files              → upload file (multipart), auto-versions if same name exists
DEL  /api/tickets/:id/files/:filename    → delete file
GET  /api/tickets/:id/links              → read links.md as structured array
POST /api/tickets/:id/links              → add a link { label, url }
DEL  /api/tickets/:id/links/:index       → remove a link by index
GET  /api/tickets/:id/versions/:filename → list versions of a file from .versions/
GET  /api/tickets/:id/versions/:filename/:version → read a specific version
POST /api/tickets/:id/restore/:filename/:version  → restore a version as latest
POST /api/tickets/:id/park               → run agent with parkPrompt in ticket folder
POST /api/tickets/:id/reconstruct        → run agent with reconstructPrompt in ticket folder
```

---

## Versioning Rules

When a file is uploaded and a file with the same name already exists in the ticket folder:

1. Copy the **existing** file into `.versions/` with a timestamp suffix: `filename.YYYY-MM-DD.ext`
2. If a file with that timestamp already exists (multiple uploads same day), append a counter: `filename.YYYY-MM-DD.2.ext`
3. If a change note was provided in the upload request, save it as `filename.YYYY-MM-DD.note.txt`
4. Write the new file at the root level, replacing the old one

The working directory always contains only the **latest** version of each file. `.versions/` is the archive. The UI surfaces version history per file but hides the `.versions/` folder from the main file list.

Applies to all file types: `.pdf`, `.docx`, `.png`, `.jpg`, `.txt`, `.md`, `.sql`, `.xlsx`, etc.

Does **not** apply to: `context.md`, `links.md`, `AGENT.md`, `notes.md` — these are managed by the app directly and use their own prepend/append conventions instead of file versioning.

---

## Agent Runner

When Park or Reconstruct is triggered:

1. Server spawns the configured agent CLI as a child process
2. Working directory is set to the ticket folder (`~/work-contexts/ABC-123/`)
3. The prompt is passed as a command-line argument or via stdin depending on the agent
4. Output (stdout + stderr) is streamed to the frontend via SSE (Server-Sent Events)
5. The agent has full access to all files in the folder and can read/write freely
6. The frontend shows a live terminal-style output panel while the agent runs
7. On completion, the frontend refreshes the file list (context.md will have been updated by the agent)

The app does **not** interpret or process agent output. It streams it raw. The agent is responsible for writing back to `context.md`.

Agent CLI invocation pattern (configurable):
```bash
# Claude Code
claude --print "{prompt}"

# Codex
codex "{prompt}"

# Custom / future
any-cli-command "{prompt}"
```

---

## UI — Five Views

### 1. Ticket List (home)
- List of all ticket folders, sorted by last modified date (most recent first)
- Each card shows: ticket name, last modified timestamp, status badge (Active / Paused / Done — stored in a `status` field in `context.md` frontmatter)
- Filter bar: All / Active / Paused / Done
- Button: `+ New Ticket`

### 2. New Ticket Modal
Fields:
- Ticket name / ID (required, becomes folder name) e.g. `ABC-123`
- Display label (optional, e.g. "Sample Feature")
- Status (Active / Paused / Done)
- Initial links (label + URL pairs, can add multiple)

On create: folder is created, `links.md` is initialized with provided links, `AGENT.md` is created with a default template the user can edit, `context.md` is created empty.

### 3. Ticket Workspace (main view, 3-panel layout)

```
┌─────────────────────────────────────────────────────────────────┐
│  ABC-123  Sample Feature          [Park] [Reconstruct]│
├──────────────┬─────────────────────────┬───────────────────────┤
│  FILES       │  CONTEXT                │  LINKS                 │
│              │                         │                         │
│  context.md  │  [latest context.md     │  Figma  ↗              │
│  notes.md    │   content rendered      │  Confluence  ↗         │
│  AGENT.md    │   here]                 │  ADO PR  ↗             │
│  query.sql   │                         │  Staging  ↗            │
│  design.png  │                         │                         │
│              │  Last updated: 2h ago   │  + Add link            │
│  [+ Add file]│  [View history]         │                         │
│  [drag here] │                         │                         │
└──────────────┴─────────────────────────┴───────────────────────┘
```

**Files panel:**
- List of files in ticket folder (excluding `.versions/`, `links.md`, `context.md` shown separately)
- Click to preview (text files inline, images inline, others download)
- Right-click or hover menu: Download, View versions, Delete
- Drag-and-drop upload zone at bottom
- If same filename dropped: show modal asking "This file already exists. Upload as new version?" with optional change note field

**Context panel:**
- Renders `context.md` as markdown
- "View history" opens version timeline (list of past context snapshots with timestamps)
- User can click any past version to read it
- "Notes" tab switches to `notes.md` — free-form editable textarea, saves on blur

**Links panel:**
- Label + URL pairs from `links.md`
- Each opens in new tab
- Inline "Add link" form: label field + URL field + Add button
- Delete icon per link

### 4. Agent Output Panel
- Slides in from bottom when Park or Reconstruct is triggered
- Terminal-style dark panel, monospace font
- Streams agent stdout/stderr in real time via SSE
- Shows: agent name, prompt sent, live output, completion status
- Dismissible after completion
- On completion: auto-refreshes context panel

### 5. File Version History Modal
- Triggered by "View versions" on any file
- Timeline list: each version shows filename, date, change note (if exists)
- Actions per version: Open / Download / Restore as latest
- Restore creates a new version of the current file before overwriting

---

## Status Management

Status is stored as frontmatter at the top of `context.md`:

```
---
status: active
ticket: ABC-123
label: Sample Feature
lastParked: 2025-01-28T09:00:00Z
---

[context content below]
```

The server reads this frontmatter for the ticket list view. Status can be changed from the workspace header without running the agent.

---

## Auto-start Setup

The app should include a setup script (`setup.sh`) that:
1. Installs npm dependencies
2. Creates `config.json` with defaults if not exists
3. Registers the server as a systemd service (Linux) or launchd plist (macOS)
4. Enables and starts the service
5. Prints: "Work Context running at http://localhost:3000"

After setup, the app starts automatically on boot. User never manually runs `node server.js`.

---

## What This App Deliberately Does NOT Do

- No authentication (localhost only, single user)
- No cloud sync
- No Jira/ADO API calls (the agent does this if instructed via AGENT.md)
- No built-in AI / LLM
- No diff viewer (agent handles diff reasoning)
- No git integration (use git directly in the folder if needed)
- No database
- No user accounts

---

## AGENT.md Default Template

Created automatically when a new ticket folder is made:

```markdown
# Agent Instructions for {{TICKET_NAME}}

## Jira Ticket
URL: (paste your Jira ticket URL here)

## What to do when Parked
1. Read context.md for current state
2. Read all files in this folder for additional context
3. Fetch the Jira ticket at the URL above and note any changes since last park
4. Write a new summary block at the top of context.md with:
   - Timestamp
   - Current status summary
   - Last action taken
   - Exact next step
   - Any blockers

## What to do when Reconstructing
1. Read context.md history (all versions)
2. Read all files in this folder
3. Give a concise re-entry brief covering:
   - What this ticket is about
   - Where I left off
   - What changed since last session (check Jira)
   - What to do first
```

---

## File Size & Type Limits

- No enforced file type restrictions — accept anything
- Warn (not block) if file exceeds 50MB
- Images: `.png`, `.jpg`, `.gif`, `.webp` — preview inline in UI
- Text: `.md`, `.txt`, `.sql`, `.json`, `.csv`, `.js`, `.ts`, `.cs`, `.html` — render inline
- Binary: `.pdf`, `.docx`, `.xlsx` — download only, no inline preview
- Videos: not recommended, but not blocked

---

## Out of Scope for V1 (future consideration)

- Search across all tickets
- Tagging / labeling tickets beyond status
- Exporting a ticket workspace as zip
- Sharing workspaces with team members
- Mobile view
