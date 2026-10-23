---
type: plan
ticket: <{{TICKET_EXAMPLE}} or short-kebab-slug>
title: <short title>
status: <draft | approved | in-progress | implemented | done>
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
features: ["[[feature-page-name]]"]
jira: {{JIRA_BASE_URL}}/<ID>
---
# <Request ID and title>

## Checkpoint

Updated: <YYYY-MM-DD>  
Doing: <current step>  
Decisions: <decisions made so far, or where they are listed below>  
Waiting on: <person, answer, or build>  
Next step: <what to do on return>

Code checked: <commit or branch>

## Request

<What the requester wants, with a link to the original request. Distinguish explicit requirements from interpretation.>

## Current behavior

<What the feature does now, with code evidence and links to feature pages.>

## Proposed change

<How behavior would differ. State any assumptions.>

## Impact map

| Feature or component | Current connection | Expected change or risk | Evidence                             |
|----------------------|--------------------|-------------------------|--------------------------------------|
| <area>               | <relationship>     | <effect>                | <repo-relative path or feature page> |

## Questions and decisions

<Missing requirements, choices, and decisions with their sources.>

## Verification

<Acceptance examples and regression checks tied to the impact map.>

## Follow-up

<Feature pages to update after implementation is verified.>
