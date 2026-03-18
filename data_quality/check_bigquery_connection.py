from sqlalchemy import create_engine, text

connection_string = "bigquery://<your_gcp_project_id>/olist_analytics"

engine = create_engine(connection_string)

with engine.connect() as conn:
    result = conn.execute(text("SELECT 1 AS ok"))
    for row in result:
        print(dict(row._mapping))

print("BigQuery SQLAlchemy connection succeeded.")
