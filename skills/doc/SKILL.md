---
name: doc
description: Use when writing an HTML technical document - a doc for a complex ticket (how today's code works and how the change alters it), or an explainer for a technique or concept the user asks about and does not know yet (for example "what is pixel tracking"). Works in any repo. Skip for simple tickets.
---

# Technical document

One self-contained HTML page on Web Awesome, Mermaid and Highlight.js. The look comes from a small block of Web
Awesome token overrides, so there are no handmade components to maintain.

| Situation                                            | Write      |
|------------------------------------------------------|------------|
| Complex ticket: several flows, services or decisions | Ticket doc |
| Reviewing another developer's build of a ticket      | Review doc |
| User asks about a technique or concept new to them   | Explainer  |
| Simple ticket, one obvious change                    | Nothing    |

1. Pick the place and the name, per "File names" in `rules.md`. Ticket doc: `wiki/tickets/<ID>/doc.html` in a WorkCtx
   repo. Explainer: `<topic>.html` in the repo's docs folder; ask when there is none.
2. Gather content from the code, the ticket plan or cited sources. Verify every claim and diagram label.
3. Copy `template.html` from this folder and fill it in. Never write the page from scratch: the template holds the
   theme tokens, layout CSS, diagram drag and zoom, runbook, Copy and saved ticks. Replace `TICKET-ID`, the title,
   the epic line, the summary and `KEY_PREFIX` (a new prefix per doc), then swap every sample for verified content.
   Add CSS only for layout the template lacks, never colors; use a Web Awesome component before writing a new one.
4. A review doc starts from the same template; only the section order differs. Follow `rules.md` in this folder: header, headings, color, diagrams, section order, decisions, runbook.
5. Write in the project's doc style. Write dates only when known.
6. Check light and dark, every diagram, and Copy (also when the file is opened from disk). Give the user the path.

Keep a ticket doc in step with its plan: when a decision or the code changes, update both.
