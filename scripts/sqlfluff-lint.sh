#!/usr/bin/env bash
# Used by pre-commit: load local Snowflake env for SQLFluff's dbt templater, then lint.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
else
  echo "sqlfluff-lint.sh: no .env in repo root — dbt templater may fail (use .env.example)." >&2
fi

exec uv run sqlfluff lint "$@"
