Run the following steps in order:

**1. Sync with default branch**
Run `git remote show origin | grep 'HEAD branch'` to detect the default branch (e.g. main).
Run `git fetch origin` then `git merge origin/<default-branch>` to pull in latest changes.
If there are merge conflicts, stop and tell the user: list the conflicting files and ask them to resolve conflicts and re-run /finish-work.

**2. Review commits on this branch**
Run `git log origin/<default-branch>..HEAD --oneline` to list all commits on the branch.
If there are any commits whose messages do not follow conventional commits format (feat:, fix:, chore:, refactor:, docs:, test:, ci:), tell the user which ones need updating and ask them to amend or reword them before continuing.

**3. Push to remote**
Run `git push` to push all commits to the remote branch.

**4. Update PR description**
Run `git log origin/<default-branch>..HEAD --pretty=format:"%s%n%b"` to get full commit details.
Run `gh pr view --json title,number` to get the current PR.

Write a PR description based on the commit history using this structure:
- ## Summary — bullet points of what changed and why (derived from commit messages and bodies)
- ## Changes — grouped by type (feat, fix, chore, etc.)
- ## Test plan — a markdown checklist of what should be verified

Run `gh pr edit --title "<title>" --body "<description>"` to update the PR.
The title should follow conventional commits format and summarise the branch work.

**5. Mark PR as ready for review**
Run `gh pr ready` to convert the draft PR to ready for review.

Output the PR URL and ask: "What shall we do?"
