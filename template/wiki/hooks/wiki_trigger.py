# UserPromptSubmit hook: reminds Claude of the wiki skills the first time a ticket is mentioned in a session.
# Claude judges the intent; the hook only detects a ticket ID. Prints nothing otherwise and never fails the prompt.
import json, os, re, sys, tempfile

TICKET_PATTERN = r"{{TICKET_PATTERN}}"

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

prompt = data.get("prompt", "")
# Reports from subagents arrive as prompts too; they must not use up the first-mention reminder.
if not TICKET_PATTERN or "<agent-message" in prompt or "[Subagent hand-back]" in prompt:
    sys.exit(0)

tickets = {t.upper() for t in re.findall(TICKET_PATTERN, prompt, re.IGNORECASE)}
seen_file = os.path.join(tempfile.gettempdir(), "claude-wiki-trigger-" + re.sub(r"\W", "", data.get("session_id", "x")))
try:
    seen = set(open(seen_file).read().split())
except OSError:
    seen = set()

new = sorted(tickets - seen)
if not new:
    sys.exit(0)
try:
    with open(seen_file, "a") as f:
        f.write(" ".join(new) + " ")
except OSError:
    pass

context = (f"Ticket mentioned for the first time this session: {', '.join(new)}. Judge the user's intent: "
           "starting or returning to work on it -> run the `start` skill first and stop before code; "
           "asking for an impact assessment or implementation plan -> run `plan`; "
           "the user says this ticket's work is complete -> run `learn`; anything else (a question, a side remark) -> no skill.")
print(json.dumps({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": context}}))
