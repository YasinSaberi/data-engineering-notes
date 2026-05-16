## task 1
import pandas as pd

sf = pd.read_csv("sales.csv")
print("before cleaning: ")
print(sf.info())

# data cleaning
sf.drop_duplicates(inplace=True)
sf.dropna(inplace=True)
print("\nafter cleaning")
print(sf.info())

sf["total_revenue"] = sf["price"] * sf["quantity"]
grand_totla = sf["total_revenue"].sum()
avg = sf["total_revenue"].mean()
product_count = sf["product"].value_counts()

print("\npreview: ")
print(sf.head())
print("\nnumeric summary: ")
print(sf.describe())

print("\nprice consistency per product: ")
print(sf.groupby("product")["price"].nunique())
print("\nquantity distribution: ")
print(sf["quantity"].describe())

print("\n===== SALES REPORT =====")
print("total revenue: ", grand_totla)
print("avrage: ", avg)
print("\norder per product: ")
print(product_count)

# TASK 2
import pandas as pd

# Load
jf = pd.read_json("users.json")

# IDENTIFICATION
print("--- DATA HEALTH CHECK ---")
print(f"Total Records: {len(jf)}")
print(jf.isnull().sum()) 
print(jf.dtypes)

# ANALYSIS 
unique_countries = jf['country'].dropna().unique()
print(f"\nUnique Countries ({len(unique_countries)}): {unique_countries}")

# DATA CLEANING
jf.drop_duplicates(inplace=True)
jf['age'] = jf['age'].fillna(jf['age'].median()).astype(int)
jf['country'] = jf['country'].fillna("Unknown")

# REPORT
print("\n--- CLEANED DATA PREVIEW ---")
print(jf.head())
print(jf.describe())
