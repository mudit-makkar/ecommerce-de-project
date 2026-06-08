import pandas as pd
import os

data_path = "data/raw"
files = os.listdir(data_path)

for f in sorted(files):
    if f.endswith('.csv'):
        df = pd.read_csv(f"{data_path}/{f}")
        print(f"\n{'='*60}")
        print(f"FILE: {f}")
        print(f"  Rows: {len(df):,}")
        print(f"  Columns: {list(df.columns)}")
        print(f"  Nulls:\n{df.isnull().sum()[df.isnull().sum() > 0].to_string()}")
        print(f"\n  Sample row:")
        print(df.iloc[0].to_string())
