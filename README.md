# snowflake_analytics (dbt on Snowflake)

Medallion-style dbt project for Airbnb-style **listings / bookings / hosts** data: raw staging sources through **bronze → silver → gold**, with **SCD2 snapshots** for dimension history.

## Architecture

| Layer | Location | Role |
|--------|----------|------|
| **Sources** | `models/sources/sources.yml` | `AIRBNB.staging` tables: `listings`, `bookings`, `hosts` |
| **Bronze** | `models/bronze/` | Incremental models from staging (schema `bronze`) |
| **Silver** | `models/silver/` | Cleaned / enriched incrementals (schema `silver`, materialized as tables) |
| **Gold** | `models/gold/` | `obt` wide mart, `fact`, and `ephemeral/` models used as snapshot inputs (schema `gold`) |
| **Snapshots** | `snapshots/` | Type-2 dims: `dim_bookings`, `dim_hosts`, `dim_listings` (timestamp strategy, schema `gold`) |

Project name in `dbt_project.yml` is **`snowflake_analytics`**; dbt profile: **`dbt_snowflake`**.

## Prerequisites

- Python **3.13+** and [**uv**](https://docs.astral.sh/uv/) (`>=0.6.8`)
- Snowflake credentials exposed as **environment variables** read by **`profiles.yml`** (repo root). CI uses the same names as GitHub Actions secrets — see `.github/workflows/dbt-ci.yml`.

## Environment variables

[`profiles.yml`](profiles.yml) maps these to the **`dbt_snowflake`** profile (defaults in the profile are placeholders like `CHANGEME`; set real values in your shell or `.env`):

| Variable | Purpose |
|----------|---------|
| `DBT_SNOWFLAKE_ACCOUNT` | Snowflake account locator |
| `DBT_SNOWFLAKE_USER` | Login user |
| `DBT_SNOWFLAKE_PASSWORD` | Password |
| `DBT_SNOWFLAKE_ROLE` | Role |
| `DBT_SNOWFLAKE_DATABASE` | Default database (**required** by snapshot configs; see `snapshots/*.yml`) |
| `DBT_SNOWFLAKE_WAREHOUSE` | Warehouse |
| `DBT_SNOWFLAKE_SCHEMA` | Default schema for the dev target |

**Local:** copy [`.env.example`](.env.example) to `.env` and edit (`.env` is gitignored):

```bash
cp .env.example .env
```

### Exporting `.env` in bash (`set -a`)

[`set -a`](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html) (allexport) makes every variable defined or reassigned afterward **exported** to child processes until you turn it off with `set +a`. Typical pattern:

```bash
cd /path/to/dbt_snowflake
set -a
source .env
set +a
uv run dbt parse --project-dir . --profiles-dir .
```

**Without `set -a`**, vars from `source .env` are usually shell-only unless the file lines use `export FOO=...`; dbt resolves `env_var(...)` via the process environment when it loads `profiles.yml`, so exporting matters for `uv run dbt`.

**Makefile:** targets such as `make dbt-run` already run `set -a && source .env && set +a` when `.env` exists, so duplicates are exported for that subprocess.

Other options: [`direnv`](https://direnv.net/), or exporting vars in CI (the workflow sets the same keys from repository secrets).

## Setup

```bash
uv sync --frozen --group dev
cp .env.example .env   # then edit .env
make dbt-deps
```

## Common commands

| Command | Purpose |
|---------|---------|
| `make dbt-parse` | Validate project |
| `make dbt-run` | Run models |
| `make dbt-build` | Run + test (per dbt build) |
| `make dbt-test` | Tests only |
| `make lint` / `make fmt` | Ruff + SQLFluff on SQL paths |
| `uv run dbt snapshot` | Build / refresh snapshot tables (after models they `ref`) |

Run `make help` for the full list.

## Tooling

- **SQLFluff** (dbt templater) and **Ruff** — see `Makefile`, `scripts/`, `.sqlfluff`
- **pre-commit** — `.pre-commit-config.yaml`
- **CI** — `.github/workflows/dbt-ci.yml`
