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
