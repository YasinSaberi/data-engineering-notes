import pandas as pd

es = pd.read_csv("employees.csv")

print("Before cleaning: \n")
print(es.info())
print(es.nunique())

print("Data cleaning procces:\n")
es.drop_duplicates(inplace=True)
es["department"] = es["department"].str.upper()
es["hire_date"] = pd.to_datetime(es["hire_date"], errors='coerce')
salary_mean = es["salary"].mean()
es["salary"] = es["salary"].fillna(salary_mean).astype(int)
es.dropna(inplace=True)

print(es.info())
print(es.head())
