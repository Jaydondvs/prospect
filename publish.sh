#!/bin/zsh
# Commit every change and push to GitHub. GitHub Pages redeploys automatically (~1 min).
# Usage: ./publish.sh "What changed"
set -e
cd "$(dirname "$0")"
msg="${1:-Update Prospect}"
git add -A
if git diff --cached --quiet; then echo "Nothing to publish."; exit 0; fi
git commit -m "$msg"
git push
echo "Published. Live in about a minute."
