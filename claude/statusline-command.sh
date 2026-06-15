#!/bin/sh
input=$(cat)

user=$(whoami)
host=$(hostname -s)
dir=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Git branch (skip optional locks)
branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Build prompt segments
location="${user}@${host} ${dir}"
[ -n "$branch" ] && location="${location} [${branch}]"

ctx=""
[ -n "$used" ] && ctx=" | ctx:$(printf '%.0f' "$used")%"

printf "%s | %s%s" "$location" "$model" "$ctx"
