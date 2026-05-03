#!/usr/bin/env bash
# Load local Snowflake env for SQLFluff's dbt templater, then apply fixes.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
else
  echo "sqlfluff-fix.sh: no .env in repo root — dbt templater may fail (use .env.example)." >&2
fi

exec uv run sqlfluff fix "$@"
