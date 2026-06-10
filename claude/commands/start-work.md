Use the AskUserQuestion tool (single-select, header: "Ticketing system") to ask:
"Which ticketing system are you using?"
- Label: "Linear", description: "e.g. ENG-123"
- Label: "Jira", description: "e.g. PROJ-456"
- Label: "GitHub Issues", description: "e.g. #42"
- Label: "None", description: "No ticket — I'll describe what I'm doing"

Then collect the remaining info conversationally:
- If Linear/Jira: ask "Ticket ID?" then "Short description?"
- If GitHub Issues: ask "Issue number?" then "Short description?"
- If None: ask "What are you working on?"

Branch naming:
- Linear: `feature/ENG-123-short-description`
- Jira: `feature/PROJ-456-short-description`
- GitHub Issues: `feature/42-short-description`
- None: `feature/short-description`

Branch name rules: lowercase, words separated by hyphens, no special characters, max 50 chars total.

Then run these steps in order using bash:
1. `git checkout -b <branch-name>`
2. `git push -u origin <branch-name>`
3. `gh pr create --draft --title "<description>" --body ""`

After the PR is created, output the PR URL and ask: "What shall we do?"
