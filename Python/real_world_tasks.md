# Pandas Real‑World Exercises

This document contains **real‑world, scenario‑based exercises** designed to solidify practical understanding of the Pandas library.

⚠️ **Rules**
- Do NOT jump to solutions.
- Focus on reasoning, data inspection, and justification of each transformation.
- Treat every task as production‑grade data work.

---

## ✅ Beginner Level — Pandas Fundamentals

### Task 1: Sales Summary Report

**Context**  
You work for a small retail store and receive daily sales logs.

**Objectives**
- Load the data
- Inspect structure and data types
- Calculate:
  - Total revenue
  - Average order value
  - Number of orders per product
- Identify obvious data quality issues

**Data Sample (`sales.csv`)**
```csv
order_id,order_date,product,quantity,price
1001,2024-01-01,Keyboard,2,25.5
1002,2024-01-01,Mouse,1,15
1003,2024-01-02,Monitor,1,210
1004,2024-01-02,Keyboard,1,25.5
1005,2024-01-03,Mouse,3,15
1006,2024-01-03,Keyboard,2,25.5
1007,2024-01-04,Monitor,1,210
1008,2024-01-04,Mouse,2,15
1009,2024-01-05,Keyboard,1,25.5
1010,2024-01-05,Monitor,2,210
1011,2024-01-06,Mouse,1,15
1012,2024-01-06,Keyboard,3,25.5

---

### Task 2: User Profile Inspection

**Context**  
You receive user profile data from a marketing team.

**Objectives**
- Load JSON data
- Convert to DataFrame
- Identify:
  - Missing values
  - Data types
  - Unique countries
- Produce a clean preview for reporting

**Data Sample (`users.json`)**
json
[
  {"user_id": 1, "name": "Alice", "age": 29, "country": "Germany"},
  {"user_id": 2, "name": "Bob", "age": null, "country": "France"},
  {"user_id": 3, "name": "Carlos", "age": 34, "country": "Spain"},
  {"user_id": 4, "name": "Diana", "age": 41, "country": "Germany"},
  {"user_id": 5, "name": "Eva", "age": 25, "country": null},
  {"user_id": 6, "name": "Frank", "age": 38, "country": "France"},
  {"user_id": 7, "name": "Grace", "age": 29, "country": "Italy"},
  {"user_id": 8, "name": "Hassan", "age": 45, "country": "Germany"}
]

---

## ⚙️ Intermediate Level — Cleaning & Analysis

### Task 3: Employee Records Cleanup

**Context**  
HR data exported from multiple legacy systems.

**Objectives**
- Detect and fix:
  - Wrong date formats
  - Inconsistent department names
  - Missing salaries
- Remove duplicate employees
- Prepare a clean dataset ready for analytics

**Data Sample (`employees.csv`)**
csv
emp_id,name,department,hire_date,salary
E001,John Smith,IT,2019/03/15,55000
E002,Sara Khan,HR,15-04-2020,48000
E003,Ali Reza,it,2021-06-01,52000
E004,Maria Lopez,Finance,2020/11/20,
E005,Chen Wei,finance,2018-01-10,61000
E006,John Smith,IT,2019/03/15,55000
E007,Fatima Noor,HR,2022-08-01,47000
E008,Lucas Brown,IT,2021/13/01,50000
E009,Anna Müller,Finance,2017-09-05,64000
E010,Sara Khan,HR,15-04-2020,48000
E011,David Kim,IT,2023-02-14,51000
E012,Omar Saleh,HR,,46000
E013,Elena Rossi,Finance,2019-07-30,59000
E014,Yuki Tanaka,IT,2020-05-18,53000

---

### Task 4: Customer Behavior Analysis

**Context**  
Online store transaction data.

**Objectives**
- Create calculated columns
- Analyze purchasing patterns
- Identify:
  - High‑value customers
  - Most profitable category
- Check correlations between numeric features

**Data Sample (`transactions.csv`)**
csv
customer_id,category,items_purchased,total_amount,visit_duration
C001,Electronics,3,320,12.5
C002,Clothing,5,180,25
C003,Electronics,1,120,8
C004,Home,4,260,18
C005,Clothing,2,90,10
C006,Electronics,6,540,30
C007,Home,1,70,6
C008,Electronics,2,210,15
C009,Clothing,4,160,22
C010,Home,3,240,20
C011,Electronics,5,480,28
C012,Clothing,1,45,5
C013,Home,2,150,12
C014,Electronics,4,390,24
C015,Clothing,3,135,16

---

## 🔥 Challenge Level — Real‑World Data Risk

### Task 5: Monthly Performance Dashboard Prep

**Context**  
You are preparing data for executive reporting.

**Objectives**
- Parse dates and extract month/year
- Aggregate metrics by month and region
- Handle missing and inconsistent values
- Validate numerical correctness

**Data Sample (`performance.csv`)**
csv
date,region,leads,conversions,revenue
2024-01-05,EU,120,15,15000
2024-01-18,EU,95,10,9800
2024-01-25,US,200,25,27000
2024-02-03,EU,110,14,14000
2024-02-15,US,210,28,30000
2024-02-28,US,190,23,
2024-03-02,EU,130,18,17500
2024-03-14,EU,,16,16000
2024-03-20,US,220,30,32000
2024-03-29,US,205,27,29500
2024-04-04,EU,140,20,19000
2024-04-17,EU,150,21,20500
2024-04-25,US,230,32,35000
2024-05-06,EU,160,22,22000
2024-05-19,US,240,35,38000
2024-05-28,US,225,33,36000
2024-06-03,EU,170,24,24000
2024-06-18,US,250,38,42000

---

### Task 6: Data Integrity & Risk Detection

**Context**  
You suspect silent data issues before model training.

**Objectives**
- Detect:
  - Outliers
  - Invalid correlations
  - Suspicious duplicates
- Decide which columns are unreliable
- Prepare a data risk report

**Data Sample (`sensor_data.csv`)**
csv
timestamp,device_id,temperature,humidity,pressure
2024-07-01 10:00,A1,22.5,45,1012
2024-07-01 10:05,A1,22.6,46,1011
2024-07-01 10:10,A1,85.0,10,800
2024-07-01 10:15,A1,22.7,45,1012
2024-07-01 10:20,A1,22.8,46,1013
2024-07-01 10:00,B2,19.5,55,1009
2024-07-01 10:05,B2,19.6,54,1010
2024-07-01 10:10,B2,19.7,200,1011
2024-07-01 10:15,B2,19.6,55,1010
2024-07-01 10:20,B2,19.8,54,1011
2024-07-01 10:00,C3,25.1,40,1015
2024-07-01 10:05,C3,25.2,41,1016
2024-07-01 10:10,C3,25.3,42,1017
2024-07-01 10:15,C3,25.4,43,1018
2024-07-01 10:20,C3,25.5,44,1019

---

## 📌 Final Note

If you cannot **explain and defend** every cleaning, aggregation, or correlation decision, you are **using Pandas mechanically** — not analytically.

Treat this as **interview‑level preparation**, not tutorial practice.


---

If you want next:
- ✅ A **folder structure** for your GitHub repo  
- ✅ A **README with learning milestones**  
- ✅ A **separate “solution” branch strategy**  

Say which one.
