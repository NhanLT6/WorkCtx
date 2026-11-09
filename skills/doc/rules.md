# Doc rules

Structure and headings carry understanding. Color only marks what needs attention.

## Stack and theme

- Web Awesome for components, Mermaid for diagrams, Highlight.js for code (lighter than Prism). Pin every CDN version.
- Change the look only through Web Awesome tokens, kept in the first `<style>` block: fonts, surface, border and text
  colors, for light and dark.
- Theme: Shoelace (`wa-theme-shoelace`) under the token block. Matter is a Pro theme, not on the public CDN. The dark
  surfaces sit a step lighter than Shoelace's near black, for easier text contrast.
- Fonts: Bricolage Grotesque for headings, Figtree for body, JetBrains Mono for code. Body text 16px.
- Content is left-aligned next to the Contents panel, not centered.
- Mermaid reads every color from the tokens through the template's `tok()`. A source can name a token in braces:
  `linkStyle 0 stroke:{--wa-color-brand-border-loud}`.
- Draw Mermaid after `document.fonts.ready`; labels are measured at render time.
- Render each diagram with `mermaid.render` and its own id. `mermaid.run` restarts its ids, and a redraw then fails with
  "Syntax error".
- If `wa-copy-button` fails when the file is opened from disk, fall back to a hidden textarea and
  `document.execCommand("copy")`.

## Header

- Ticket doc h1: `{ticket ID} {ticket title}`, ID in brand color, then a smaller quiet line inside the h1:
  `Epic {epic ID} {epic title}`. Leave out the epic line when there is none.
- Explainer h1: the topic name, with an optional smaller line for the context it relates to.
- Under the h1, one or two sentences: what the ticket changes and why, or what the technique is for.
- The page title block has no badges, legend, source or revision line, or second title. Sources and revisions go in
  the footer.

## Navigation and theme switch

- The page is a `wa-page`. Its sticky header holds the Contents button (left, only below 1100px), the doc title
  (always the same, it does not follow the scroll), and the Dark switch (right). No stepper, progress bar or table of
  contents inside the content.
- Contents is the `navigation` slot, built in script from the h2 and h3 headings, so it never needs editing. At 1100px
  and wider it is a left panel; below that it collapses into a drawer opened by the Contents button, like a phone menu.
  The section being read is highlighted in the menu; choosing an entry closes the drawer.
- Light or dark follows the device until the reader picks one; the pick is kept. The switch is the only theme control.

## File names

- Ticket doc: `doc.html` in the ticket folder, next to `plan.md`. A second doc for the same ticket is
  `doc-<topic>.html`.
- Explainer: `<topic>.html` in the docs folder, topic in lowercase kebab-case (`pixel-tracking.html`).
- Never `technical-document.html`, `index.html`, `map-*.html` or a name with a date or version.
- `KEY_PREFIX` in the script is `doc-<ticket ID or topic>-`, so two docs in one browser never share ticks or views.

## Headings and spacing

- h2: section number + the area it covers, as a short noun phrase ("Test journey"). No tagline or eyebrow.
- h3: only to split a section, label only ("Today", "After ABC-123"). No badge repeating the label.
- No horizontal dividers. Spacing and headings separate sections.
- Every title makes sense alone. "Dashboard" or "Q7 Design" does not; "Local test setup" does.
- No decoration without meaning (numbered circles, icons, gradients). It reads as generated.
- No manual line break or hyphen inside a heading.

## Color and badges

- Red: blocked or error only. Amber: warning. Green: pass. Brand: new or changed. Neutral: everything else.
- A flow end, a removed path, a settled item or a count is neutral. Red reads as "something is wrong".
- A legend badge sits right next to the diagram it explains, never in the header.
- "New or changed step" goes only beside a chart that uses the `changed` class.
- Use `wa-badge` as it comes. Restyling its parts draws a badge inside a badge.

## Diagrams

- Sources sit in `<script type="text/plain" class="mm">`, never in `<pre>`: the HTML parser turns `<br/>` into real
  tags and the labels run together.
- No hex colors in a source. Use the node classes (`changed`, `block`, `warn`, `ok`, `end1` for where a flow stops) or
  a token in braces.
- Hint, not a rule: for condition logic, a decision spine reads well. The happy path runs down, each failure exits to
  its own result, and the message for each result sits right below the chart. A scenario matrix with lettered
  messages reads worse.
- One full-width diagram beats two small ones side by side. A before and after state change fits in one chart: the
  removed edge dashed grey, the new edge brand.
- Before and after flows: plain steps keep a neutral fill and grey border. New or changed steps use the `changed`
  class (brand fill, 2px loud border), with a "New or changed step" badge beside the heading.
- Bold the first line of each node label.
- Notes under a diagram are visible cards (`dl.notes`), not an accordion.
- Check every label against the code or the source. Keep labels short and check none is clipped after render.
- A diagram can be dragged, zoomed with Ctrl + wheel, and has + / - / Reset buttons. Say nothing about this on the page.
- It opens at a readable scale: fit to the frame when that keeps the text at 70% or more, otherwise 85%, starting from
  the top-left. Never enlarged past natural size.
- The reader's view is saved per diagram as scale plus the drawing point at the frame center, so it survives a redraw
  and a different page width. A redraw happens on a theme change and when the page width changes.
- Check a saved view before using it. A view saved in an older shape gives NaN, and `svg-pan-zoom` throws "The provided
  float value is non-finite".
- `svg-pan-zoom` resets the view inside `destroy()` and fires its callbacks. Clear the instance before destroying it
  and ignore callbacks that arrive without one, or every redraw overwrites the saved view with the default.
- A diagram inside a closed `wa-details` has no width; set up drag and zoom when it opens.

## Section order

Ticket doc, which explains how today's code works and how the change alters it:

1. Journey today, then how the system processes it behind the scenes, then the journey after the change.
2. New logic, for example check results and their messages.
3. Each affected area in its own section. Do not bundle unrelated areas.
4. Local test setup and runbook.
5. Terms in the code.
6. QA cases and decisions.

Explainer:

1. What it is: summary and one diagram of the moving parts.
2. How it works: step flow, with notes on each step.
3. Variants or options, compared in a table.
4. Where it appears in the current codebase, when relevant and verified.
5. Limits and pitfalls.
6. Terms.
7. Sources: links the explanation is based on.

Small patterns the template has: old text and new text side by side (`.notif`), the changed part of a URL marked
inside it (`.link-sample` with `<mark>`), and a value worked out from the test values shown inline (`data-show`).

Both: keep core explanation visible. Collapse (`wa-details`) only optional long material such as a runbook, with a
summary that says what is inside. After a restructure, remove references that no longer point anywhere.

## Questions and decisions (ticket doc)

- While questions are open, list them under "Open questions", ready to ask the PO.
- A spot in a diagram that depends on an open question can carry its number (`Q1`) in the label, so the doubt shows in
  the flow. Remove it in the same update that settles the question.
- Once settled, drop the questions and keep a Decisions list: what was chosen, when (if known), why. Same content as
  the plan.
- A question still open during coding stays listed until it is settled.

## Runbook (ticket doc)

- One test values bar at the top. Every link and query in the steps uses those values.
- Order steps by what the tester does, not by diagram letter: one action per step, and the check right after the action
  that causes it.
- Steps sit in one container, separated by thin lines, with a key chip on the left (step number or diagram letter).
- Each step has aligned labeled rows: Do, Open (link), Expect, SQL. Leave out rows a step does not need.
- Code blocks have Copy, links also Open. A ticked step fades: grey chip, struck title.
- Collapsed by default, for example "Runbook: test today's flow locally, step by step with SQL".

## Audience and content

- Written for developers. No QA or reader-mode toggle; other readers skip the code.
- Ticket QA cases follow the plan's Verification list.
- A QA case that needs a recipe gets a short numbered list, linked from the case: one action per line, the last line the
  expected result. No SQL or long explanation unless asked.
