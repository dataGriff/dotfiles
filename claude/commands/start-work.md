Ask the user: "Are you working with a ticketing system? (linear / jira / devops / github / none)"

Based on their answer, collect the information needed to name the branch:

- **linear**: Ask "What's the ticket ID? (e.g. ENG-123)" then "Short description?" — branch: `feature/ENG-123-short-description`
- **jira**: Ask "What's the ticket ID? (e.g. PROJ-456)" then "Short description?" — branch: `feature/PROJ-456-short-description`
- **devops**: Ask "What's the work item ID? (e.g. 789)" then "Short description?" — branch: `feature/789-short-description`
- **github**: Ask "What's the issue number? (e.g. 42)" then "Short description?" — branch: `feature/42-short-description`
- **none**: Ask "What are you working on?" — branch: `feature/short-description`

Branch name rules: lowercase, words separated by hyphens, no special characters, max 50 chars total.

Then run these steps in order using bash:
1. `git checkout -b <branch-name>`
2. `git push -u origin <branch-name>`
3. `gh pr create --draft --title "<description>" --body ""`

After the PR is created, output the PR URL and ask: "What shall we do?"
