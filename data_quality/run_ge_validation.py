"""
Lean GE validation runner for Dagster.

This script is intentionally simple:
- queries BigQuery marts into pandas
- applies GE validations
- exits non-zero if any table fails
"""

from __future__ import annotations

import sys

import pandas as pd
import great_expectations as gx
from google.cloud import bigquery
from great_expectations.core.expectation_suite import ExpectationSuite


PROJECT_ID = "<your_gcp_project_id>"
DATASET = "<your_dbt_dataset>"


def build_summary_rows(results, table_name: str) -> list[dict]:
    rows = []
    for r in results.results:
        config_obj = r.expectation_config
        try:
            config_dict = config_obj.to_json_dict()
        except Exception:
            config_dict = {}

        expectation = (
            config_dict.get("type")
            or getattr(config_obj, "type", None)
            or getattr(config_obj, "expectation_type", None)
            or "unknown_expectation"
        )

        kwargs = config_dict.get("kwargs") or getattr(config_obj, "kwargs", {}) or {}
        column = kwargs.get("column", "table")

        rows.append(
            {
                "table_name": table_name,
                "expectation": expectation,
                "column": column,
                "success": r.success,
            }
        )
    return rows


def validate_table(
    context,
    client: bigquery.Client,
    data_source,
    table_name: str,
    query: str,
    suite_name: str,
    not_null: list[str],
    unique: list[str],
    between: dict[str, dict],
) -> tuple[bool, pd.DataFrame]:
    df = client.query(query).to_dataframe()

    try:
        asset = data_source.get_asset(f"{table_name}_df")
    except Exception:
        asset = data_source.add_dataframe_asset(name=f"{table_name}_df")

    try:
        batch_definition = asset.get_batch_definition("batch")
    except Exception:
        batch_definition = asset.add_batch_definition_whole_dataframe("batch")

    batch = batch_definition.get_batch(batch_parameters={"dataframe": df})

    try:
        context.suites.get(name=suite_name)
    except Exception:
        context.suites.add(ExpectationSuite(name=suite_name))

    validator = context.get_validator(
        batch=batch,
        expectation_suite_name=suite_name,
    )

    for col in not_null:
        validator.expect_column_values_to_not_be_null(col)

    for col in unique:
        validator.expect_column_values_to_be_unique(col)

    for col, bounds in between.items():
        validator.expect_column_values_to_be_between(col, **bounds)

    validator.expect_table_row_count_to_be_between(min_value=1)

    suite = validator.get_expectation_suite()
    context.suites.add_or_update(suite)

    results = validator.validate()
    summary_df = pd.DataFrame(build_summary_rows(results, table_name))
    return results.success, summary_df


def main() -> int:
    gx_context = gx.get_context()
    client = bigquery.Client(project=PROJECT_ID)
    data_source = gx_context.data_sources.add_or_update_pandas(name="pandas_source")

    rules = [
        {
            "table_name": "fct_order_items",
            "query": f"SELECT * FROM `{PROJECT_ID}.{DATASET}.fct_order_items`",
            "suite_name": "fct_order_items_suite",
            "not_null": ["order_id", "order_item_id", "product_id", "seller_id", "customer_id"],
            "unique": [],
            "between": {
                "price": {"min_value": 0},
                "freight_value": {"min_value": 0},
                "gross_item_value": {"min_value": 0},
            },
        },
        {
            "table_name": "dim_customers",
            "query": f"SELECT * FROM `{PROJECT_ID}.{DATASET}.dim_customers`",
            "suite_name": "dim_customers_suite",
            "not_null": ["customer_id", "customer_state"],
            "unique": ["customer_id"],
            "between": {},
        },
        {
            "table_name": "dim_products",
            "query": f"SELECT * FROM `{PROJECT_ID}.{DATASET}.dim_products`",
            "suite_name": "dim_products_suite",
            "not_null": ["product_id"],
            "unique": ["product_id"],
            "between": {
                "product_weight_g": {"min_value": 0},
                "product_length_cm": {"min_value": 0},
                "product_height_cm": {"min_value": 0},
                "product_width_cm": {"min_value": 0},
            },
        },
        {
            "table_name": "dim_sellers",
            "query": f"SELECT * FROM `{PROJECT_ID}.{DATASET}.dim_sellers`",
            "suite_name": "dim_sellers_suite",
            "not_null": ["seller_id", "seller_state"],
            "unique": ["seller_id"],
            "between": {},
        },
        {
            "table_name": "dim_dates",
            "query": f"SELECT * FROM `{PROJECT_ID}.{DATASET}.dim_dates`",
            "suite_name": "dim_dates_suite",
            "not_null": ["date_id"],
            "unique": ["date_id"],
            "between": {
                "month": {"min_value": 1, "max_value": 12},
                "day_of_week": {"min_value": 1, "max_value": 7},
            },
        },
    ]

    all_ok = True
    master_rows = []

    for rule in rules:
        success, summary_df = validate_table(
            context=gx_context,
            client=client,
            data_source=data_source,
            table_name=rule["table_name"],
            query=rule["query"],
            suite_name=rule["suite_name"],
            not_null=rule["not_null"],
            unique=rule["unique"],
            between=rule["between"],
        )
        print(f"{rule['table_name']}: success={success}")
        master_rows.extend(summary_df.to_dict("records"))
        all_ok = all_ok and success

    master_df = pd.DataFrame(master_rows)
    print("\nValidation summary:")
    print(master_df.groupby(["table_name", "success"]).size())

    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())