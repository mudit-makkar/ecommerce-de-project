import snowflake.connector
import pandas as pd
import numpy as np
import os
from dotenv import load_dotenv

load_dotenv()

# -----connection----
conn = snowflake.connector.connect(
        account = os.getenv("SNOWFLAKE_ACCOUNT"),
        user = os.getenv("SNOWFLAKE_USER"),
        password = os.getenv("SNOWFLAKE_PASSWORD"),
        warehouse = os.getenv("SNOWFLAKE_WAREHOUSE"),
        database = os.getenv("SNOWFLAKE_DATABASE"),
        schema = os.getenv("SNOWFLAKE_SCHEMA"),
)

cursor = conn.cursor()

# ── file → table mapping ─────────────────────────────────────
FILES = {
    "olist_orders_dataset.csv":                    "ORDERS",
    "olist_order_items_dataset.csv":               "ORDER_ITEMS",
    "olist_customers_dataset.csv":                 "CUSTOMERS",
    "olist_products_dataset.csv":                  "PRODUCTS",
    "olist_sellers_dataset.csv":                   "SELLERS",
    "olist_order_payments_dataset.csv":            "ORDER_PAYMENTS",
    "olist_order_reviews_dataset.csv":             "ORDER_REVIEWS",
    "olist_geolocation_dataset.csv":               "GEOLOCATION",
    "product_category_name_translation.csv":       "PRODUCT_CATEGORY_NAME_TRANSLATION",
}

DATA_PATH = '~/projects/ecommerce-de-project/data/raw'

for filename, table in FILES.items():
        filepath = f"{DATA_PATH}/{filename}"
        print(f"\nLoading {filename} -> {table}")

        df = pd.read_csv(filepath, dtype=str) # dtype=str keeps everything as string
        df = df.where(pd.notnull(df), None)
        df = df.replace({ np.nan: None})

        cols = list(df.columns)
        col_str = ', '.join(cols)
        placeholder = ", ".join(["%s"] * len(cols))
        sql = f"INSERT INTO {table} ({col_str}) VALUES ({placeholder})"
        print(sql)

        # write in batches of 5000 rows (faster than row-by-row)
        batch_size  = 5000
        total_rows  = len(df)
        rows_loaded = 0

        for i in range(0, total_rows, batch_size):
                batch = df.iloc[i:i+batch_size]
                data = [row for row in batch.itertuples(index=False, name=None)]
                cursor.executemany(sql, data)
                rows_loaded += len(batch)
                print(f"  {rows_loaded:,} / {total_rows:,} rows", end="\r")
        
        print(f"  ✅ {total_rows:,} rows loaded into {table}")

conn.commit()
cursor.close()
conn.close()
print("\n🎉 All tables loaded successfully!")
