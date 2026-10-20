#!/usr/bin/env bash
#
# IOTBTECH 2026 Capstone — install git hooks
# Run once per clone:  bash scripts/setup-hooks.sh
#
# This points git at the version-controlled scripts/git-hooks/ directory
# instead of copying files into .git/hooks/. Two reasons:
#   1. A global core.hooksPath (Husky, dotfiles, a tutorial you followed)
#      silently overrides .git/hooks/ — so a copied hook can look installed
#      and do absolutely nothing. A repo-local setting always wins.
#   2. Hooks stay version-controlled: update the hook in a PR and everyone
#      gets it, without reinstalling.
#
set -euo pipefail

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: not inside a git repository. cd to the repo root first."
  exit 1
fi

cd "$(git rev-parse --show-toplevel)"

if [ ! -d "scripts/git-hooks" ]; then
  echo "Error: scripts/git-hooks/ not found at the repo root."
  echo "Copy it from the capstone handbook templates first."
  exit 1
fi

PREVIOUS_GLOBAL="$(git config --global --get core.hooksPath || true)"

chmod +x scripts/git-hooks/* 2>/dev/null || true
git config core.hooksPath scripts/git-hooks

ACTIVE="$(git config --get core.hooksPath || true)"
if [ "$ACTIVE" != "scripts/git-hooks" ]; then
  echo "Error: failed to set core.hooksPath (got '$ACTIVE'). Tell the Tech Lead."
  exit 1
fi

echo "Hooks active from scripts/git-hooks/ for this repository."
for h in scripts/git-hooks/*; do echo "  - $(basename "$h")"; done

if [ -n "$PREVIOUS_GLOBAL" ]; then
  echo ""
  echo "Note: you have a GLOBAL core.hooksPath set ($PREVIOUS_GLOBAL)."
  echo "      This repo now overrides it locally, which is what we want."
  echo "      It also means that in any repo where you have NOT run this"
  echo "      script, a copied .git/hooks/ hook would never run."
fi

echo ""
echo "Now verify it — you WANT the push below to be refused:"
echo ""
echo "    git checkout main"
echo "    git push"
echo "    # -> BLOCKED: direct push to 'main' is not allowed."
echo "    git checkout dev"
echo ""
echo "If that push SUCCEEDED, the hook is not active. Tell the Tech Lead."
