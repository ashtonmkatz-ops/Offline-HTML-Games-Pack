#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-ashtonmkatz-ops/Offline-HTML-Games-Pack}"
OUTPUT="${OUTPUT:-catalog.json}"

repo_api="https://api.github.com/repos/${REPO}"
default_branch="$(curl -fsSL "$repo_api" | jq -r '.default_branch')"
BRANCH="${BRANCH:-$default_branch}"
tree_api="https://api.github.com/repos/${REPO}/git/trees/${BRANCH}?recursive=1"

mkdir -p "$(dirname "$OUTPUT")"

curl -fsSL "$tree_api" | jq '
  [.tree[]
    | select(.type == "blob")
    | .path as $path
    | ($path | ascii_downcase) as $lower
    | select($lower | startswith("offline/"))
    | select($lower | test("\\.(html|htm)$"))
    | {
        name: ($path | split("/")[-1] | sub("\\.[^.]+$"; "")),
        path: $path,
        link: $path
      }
  ]
  | sort_by(.name | ascii_downcase)
' > "$OUTPUT"

echo "Wrote $(jq length "$OUTPUT") games to $OUTPUT"
