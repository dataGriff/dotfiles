#!/bin/sh
# SessionStart hook: inject the active OKR suite into the session.
# Prints a one-line index derived from each file's `# ` heading, then every
# active OKR in full. Exits silently when there are no active OKRs.
dir="$HOME/.claude/okrs/active"
[ -d "$dir" ] || exit 0
set -- "$dir"/*.md
[ -e "$1" ] || exit 0

printf '# Active OKR suite\n\n'
for f in "$dir"/*.md; do
  title=$(grep -m1 '^# ' "$f" | sed 's/^# //')
  echo "- ${title:-$(basename "$f")}"
done
echo
for f in "$dir"/*.md; do
  cat "$f"
  printf '\n---\n\n'
done
