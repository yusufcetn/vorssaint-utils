#!/bin/zsh
# Pulls the original project's newest commits, merges them into this fork's
# own branch, builds and installs the app. Stops before building when the
# merge conflicts, leaving the conflict to resolve by hand.
set -euo pipefail
cd "$(dirname "$0")/.."

OWN_BRANCH="custom/own-build"

[[ -z "$(git status --porcelain)" ]] || { echo "Uncommitted changes: commit or stash them first." >&2; exit 1; }

git fetch upstream
git switch "$OWN_BRANCH"

if git merge-base --is-ancestor upstream/main HEAD; then
    echo "Already up to date with upstream."
    [[ "${1:-}" == "--force" ]] || exit 0
else
    git merge --no-edit upstream/main || {
        echo "Merge conflict: resolve it, commit, then run this again." >&2
        exit 1
    }
fi

git push origin "$OWN_BRANCH" || echo "Push skipped." >&2
./build.sh --install
