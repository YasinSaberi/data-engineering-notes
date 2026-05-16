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
