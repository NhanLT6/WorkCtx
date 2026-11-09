# WorkCtx

A personal, local feature wiki and four agent skills (`start`, `plan`, `learn`, `review`) for working on tickets in a
code repo with Codex and Claude Code, plus a standalone `doc` skill for HTML technical docs in any repo. No app, no
server: markdown, `AGENTS.md`, `SKILL.md` and one install script.

```powershell
./install.ps1 -RepoPath E:\repos\MyApp -Project MyApp -TicketPattern '\bABC-\d+\b' -TicketExample ABC-123 `
              -JiraBaseUrl https://myco.atlassian.net/browse
```

Then ask your agent to start a ticket, for example "start ABC-123". Open `<repo>/wiki` in Obsidian, or in VS Code with the Foam extension (`Foam: Show Graph`), for the graph.

Read [SPEC v4](SPEC%20v4.md) for the layout, rules and reasons.
