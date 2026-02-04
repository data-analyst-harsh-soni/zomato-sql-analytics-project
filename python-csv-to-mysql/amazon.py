import pandas as pd
from sqlalchemy import create_engine
import urllib.parse
import os

DB_HOST = "localhost"
DB_USER = "root"
DB_PASSWORD = "xyz"   # 👈 sirf password change karo
DB_NAME = "zomato"

BASE_PATH = r"D:\DATA_ANALYST\SQL\DATA SET\Zomato Dataset\\"

def get_engine():
    pwd = urllib.parse.quote_plus(DB_PASSWORD)
    return create_engine(
        f"mysql+pymysql://{DB_USER}:{pwd}@{DB_HOST}/{DB_NAME}"
    )

def import_csv_raw(table_name, csv_file):
    path = BASE_PATH + csv_file

    if not os.path.exists(path):
        print(f"❌ File not found: {csv_file}")
        return

    print(f"📥 Importing {csv_file} → {table_name}")

    df = pd.read_csv(path)

    df.to_sql(
        name=table_name,
        con=engine,
        if_exists="replace",
        index=False,
        chunksize=1000
    )

    print(f"✅ {table_name} imported ({len(df)} rows)")

if __name__ == "__main__":
    try:
        print("🔗 Connecting to MySQL...")
        engine = get_engine()
        print("✅ Connected\n")

        import_csv_raw("customers", "customers.csv")
        import_csv_raw("restaurants", "restaurants.csv")
        import_csv_raw("riders", "riders.csv")
        import_csv_raw("orders", "orders.csv")
        import_csv_raw("deliveries", "deliveries.csv")  

        print("\n🎉 ALL 5 DATASETS IMPORTED SUCCESSFULLY (NO DATA CHANGE)")

    except Exception as e:
        print(f"\n❌ ERROR: {e}")
