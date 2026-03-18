"""
Minimal Dagster orchestration for the Olist analytics platform.

Flow:
1. Run dbt transformations
2. Run Great Expectations validation
3. Log pipeline completion
"""

import os
import subprocess
from pathlib import Path

from dagster import Definitions, In, Nothing, job, op
from dagster import schedule

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DBT_PROJECT_DIR = PROJECT_ROOT / "transformation" / "olist_dbt"
GE_SCRIPT_PATH = PROJECT_ROOT / "data_quality" / "run_ge_validation.py"


def _run_command(command, cwd=None):
    """Run a shell command and raise on failure."""
    result = subprocess.run(
        command,
        cwd=str(cwd) if cwd else None,
        text=True,
        capture_output=True,
        check=False,
        env=os.environ.copy(),
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"Command failed: {' '.join(command)}\n"
            f"STDOUT:\n{result.stdout}\n"
            f"STDERR:\n{result.stderr}"
        )

    return result


@op
def run_dbt_models(context):
    """Run dbt transformations."""
    context.log.info(f"Running dbt in: {DBT_PROJECT_DIR}")

    result = _run_command(["dbt", "run"], cwd=DBT_PROJECT_DIR)

    context.log.info("dbt run completed successfully.")
    if result.stdout:
        context.log.info(result.stdout)


@op(ins={"start": In(Nothing)})
def run_ge_validation(context):
    """Run Great Expectations validation script."""
    context.log.info(f"Running GE validation script: {GE_SCRIPT_PATH}")

    result = _run_command(["python", str(GE_SCRIPT_PATH)], cwd=PROJECT_ROOT)

    context.log.info("GE validation completed successfully.")
    if result.stdout:
        context.log.info(result.stdout)


@op(ins={"start": In(Nothing)})
def mark_pipeline_ready(context):
    """Final success marker."""
    context.log.info("Pipeline complete. Data is transformed, validated, and ready for BI consumption.")


@job
def olist_pipeline_job():
    ge_done = run_ge_validation(run_dbt_models())
    mark_pipeline_ready(ge_done)


@schedule(
    job=olist_pipeline_job,
    cron_schedule="0 2 * * *",  # runs at 2 AM UTC
)
def daily_olist_pipeline_schedule(_context):
    return {}


defs = Definitions(
    jobs=[olist_pipeline_job],
    schedules=[daily_olist_pipeline_schedule],
)