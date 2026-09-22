#!/usr/bin/env bash
# Scans committed-since-base and uncommitted changes for hardcoded credential patterns.
# Resolves the repo's actual default branch instead of assuming "main", so repos on
# master (or any other default) are not silently downgraded to a working-tree-only scan.
set -uo pipefail

readonly SECRET_PATTERN='(api[_-]?key|secret|password|token|aws_access|private[_-]?key)\s*[:=]|-----BEGIN.*PRIVATE KEY-----|sk_(live|test)_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}'

resolveBaseBranch() {
  local candidate
  candidate=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  if [ -n "$candidate" ]; then
    echo "$candidate"
    return 0
  fi
  for candidate in origin/main origin/master main master; do
    if git rev-parse --verify --quiet "$candidate" >/dev/null; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository — nothing to scan."
  exit 0
fi

baseBranch=$(resolveBaseBranch)

if [ -n "$baseBranch" ]; then
  echo "Base: $baseBranch — scanning $baseBranch...HEAD plus the working tree."
else
  echo "Base: none found (no origin/HEAD, main, or master) — scanning the working tree vs HEAD only."
fi

scanTarget() {
  if [ -n "$baseBranch" ]; then
    git diff "$baseBranch...HEAD"
  fi
  git diff HEAD
}

if ! scanTarget | grep -nEi "$SECRET_PATTERN"; then
  echo "No obvious secret patterns found."
fi
