# SQL Server Mastery: Window Functions - Zero to Hero

## Executive Summary

Window functions perform calculations across a set of rows related to the current row **without collapsing the result set** like `GROUP BY` does. They're essential for ranking, running totals, moving averages, and comparative analysis. **Critical insight:** Window functions execute **after** `WHERE`, `GROUP BY`, and `HAVING` but **before** `ORDER BY` in the logical query processing order. **Performance reality:** Window functions can be expensive—always index partition and order columns, and verify execution plans for sorts and spools. **Bottom line:** Master `PARTITION BY` and `ORDER BY` clauses; they control the "window" of rows for each calculation.

---

## Phase 1: Foundation - The Window Frame Concept

### 1.1 Core Syntax
```sql
<window_function> OVER (
[PARTITION BY partition_column]
[ORDER BY order_column [ASC|DESC]]
[ROWS|RANGE frame_specification]
)
```
**Key components:**
- **Window function:** `ROW_NUMBER()`, `RANK()`, `SUM()`, `AVG()`, etc.
- **PARTITION BY:** Divides result set into groups (like `GROUP BY` but doesn't collapse rows).
- **ORDER BY:** Defines logical order within each partition.
- **Frame clause:** Specifies which rows to include in calculation (default varies by function).

### 1.2 Window Functions vs. GROUP BY

```sql
-- GROUP BY: Collapses rows
SELECT Department, AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY Department;

-- Result: One row per department
-- Department | AvgSalary
-- Sales      | 60000
-- IT         | 75000

-- Window function: Preserves all rows
SELECT EmployeeID, Name, Department, Salary,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvgSalary
FROM Employees;

-- Result: All employee rows with department average added
-- EmployeeID | Name  | Department | Salary | DeptAvgSalary
-- 1          | Alice | Sales      | 50000  | 60000
-- 2          | Bob   | Sales      | 70000  | 60000
-- 3          | Carol | IT         | 80000  | 75000
```
### 1.3 Logical Query Processing Order

```sql
SELECT Department, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
FROM Employees
WHERE Salary > 50000
ORDER BY RowNum;
```
**Execution order:**
1. `FROM` Employees
2. `WHERE` Salary > 50000
3. `SELECT` with window function (ROW_NUMBER calculated here)
4. `ORDER BY` RowNum

**Critical implication:** You cannot use window functions in `WHERE` or `HAVING` clauses. Use a CTE or subquery instead.

---

## Phase 2: Ranking Functions - The Big Four

### 2.1 ROW_NUMBER() - Sequential Numbering

```sql
-- Assign unique sequential numbers
SELECT EmployeeID, Name, Department, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS OverallRank,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DeptRank
FROM Employees;
```
**Output:**

EmployeeID | Name  | Department | Salary | OverallRank | DeptRank
3          | Carol | IT         | 80000  | 1           | 1
4          | Dave  | IT         | 75000  | 2           | 2
2          | Bob   | Sales      | 70000  | 3           | 1
1          | Alice | Sales      | 50000  | 4           | 2

**Use case:** Pagination, deduplication (keep first occurrence).

### 2.2 RANK() - Ranking with Gaps

```sql
-- Same values get same rank, next rank skips numbers
SELECT Name, Score,
RANK() OVER (ORDER BY Score DESC) AS Rank
FROM TestScores;
```
**Output:**

Name  | Score | Rank
Alice | 95    | 1
Bob   | 95    | 1
Carol | 90    | 3  -- Skips rank 2
Dave  | 85    | 4

**Use case:** Sports rankings, leaderboards where ties matter.

### 2.3 DENSE_RANK() - Ranking Without Gaps

```sql
-- Same values get same rank, next rank is consecutive
SELECT Name, Score,
DENSE_RANK() OVER (ORDER BY Score DESC) AS DenseRank
FROM TestScores;

**Output:**

Name  | Score | DenseRank
Alice | 95    | 1
Bob   | 95    | 1
Carol | 90    | 2  -- No gap
Dave  | 85    | 3
```
**Use case:** Top N per category without gaps.

### 2.4 NTILE(n) - Divide into Buckets

```sql
-- Divide employees into 4 salary quartiles
SELECT Name, Salary,
NTILE(4) OVER (ORDER BY Salary) AS SalaryQuartile
FROM Employees;
```
**Output:**

| Name  | Salary | SalaryQuartile |
| `Alice` | 40000  | 1 |
| `Bob`   | 50000  | 1 |
| `Carol` | 60000  | 2 |
| `Dave`  | 70000  | 2 |
| `Eve`   | 80000  | 3 |
| `Frank` | 90000  | 3 |
| `Grace` | 100000 | 4 |
| `Henry` | 110000 | 4 |

**Use case:** Percentile analysis, A/B testing groups.

### 2.5 Comparison Table

| Function | Ties Handling | Gaps After Ties | Use Case |
|----------|---------------|-----------------|----------|
| `ROW_NUMBER()` | Arbitrary order | N/A | Unique numbering, pagination |
| `RANK()` | Same rank | Yes | Olympic-style ranking |
| `DENSE_RANK()` | Same rank | No | Top N per group |
| `NTILE(n)` | Distributed evenly | N/A | Quartiles, deciles |

---

## Phase 3: Aggregate Window Functions

### 3.1 Running Totals

```sql
-- Calculate cumulative sales by date
SELECT OrderDate, Amount,
SUM(Amount) OVER (ORDER BY OrderDate 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Orders;
```
**Simplified syntax (default frame):**
```sql
SELECT OrderDate, Amount,
SUM(Amount) OVER (ORDER BY OrderDate) AS RunningTotal
FROM Orders;
```
**Output:**

OrderDate  | Amount | RunningTotal
2024-01-01 | 100    | 100
2024-01-02 | 150    | 250
2024-01-03 | 200    | 450

### 3.2 Moving Averages

```sql
-- 7-day moving average of sales
SELECT OrderDate, Amount,
AVG(Amount) OVER (ORDER BY OrderDate 
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS MovingAvg7Day
FROM DailySales;
```
**Output:**

OrderDate  | Amount | MovingAvg7Day
2024-01-01 | 100    | 100.00  -- Only 1 row available
2024-01-02 | 150    | 125.00  -- Average of 2 rows
2024-01-03 | 200    | 150.00  -- Average of 3 rows
...
2024-01-08 | 180    | 165.71  -- Average of 7 rows

### 3.3 Comparative Analysis (Current vs. Previous)

```sql
-- Compare each month's sales to previous month
SELECT Month, Sales,
LAG(Sales, 1) OVER (ORDER BY Month) AS PrevMonthSales,
Sales - LAG(Sales, 1) OVER (ORDER BY Month) AS SalesChange,
CAST(100.0 * (Sales - LAG(Sales, 1) OVER (ORDER BY Month)) / 
LAG(Sales, 1) OVER (ORDER BY Month) AS DECIMAL(5,2)) AS PctChange
FROM MonthlySales;
```
**Output:**

Month   | Sales | PrevMonthSales | SalesChange | PctChange
2024-01 | 10000 | NULL           | NULL        | NULL
2024-02 | 12000 | 10000          | 2000        | 20.00
2024-03 | 11000 | 12000          | -1000       | -8.33

### 3.4 Partition-Level Aggregates

```sql
-- Show each employee's salary vs. department average and total
SELECT EmployeeID, Name, Department, Salary,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvg,
SUM(Salary) OVER (PARTITION BY Department) AS DeptTotal,
CAST(100.0 * Salary / SUM(Salary) OVER (PARTITION BY Department) AS DECIMAL(5,2)) AS PctOfDeptTotal
FROM Employees;
```
**Output:**

EmployeeID | Name  | Department | Salary | DeptAvg | DeptTotal | PctOfDeptTotal
1          | Alice | Sales      | 50000  | 60000   | 120000    | 41.67
2          | Bob   | Sales      | 70000  | 60000   | 120000    | 58.33
3          | Carol | IT         | 80000  | 77500   | 155000    | 51.61
4          | Dave  | IT         | 75000  | 77500   | 155000    | 48.39

---

## Phase 4: Offset Functions - LAG and LEAD

### 4.1 LAG() - Access Previous Row

```sql
-- Compare current price to previous day
SELECT Date, StockPrice,
LAG(StockPrice, 1) OVER (ORDER BY Date) AS PrevDayPrice,
LAG(StockPrice, 1, 0) OVER (ORDER BY Date) AS PrevDayPriceWithDefault
FROM StockPrices;
```
**Syntax:** `LAG(column, offset, default_value)`
- `offset`: Number of rows back (default: 1)
- `default_value`: Value when no previous row exists (default: NULL)

### 4.2 LEAD() - Access Next Row

```sql
-- Show current and next appointment time
SELECT PatientID, AppointmentTime,
LEAD(AppointmentTime, 1) OVER (ORDER BY AppointmentTime) AS NextApptTime,
DATEDIFF(MINUTE, AppointmentTime, 
LEAD(AppointmentTime, 1) OVER (ORDER BY AppointmentTime)) AS MinutesUntilNext
FROM Appointments;
```
### 4.3 Multi-Row Offset

```sql
-- Compare current quarter to same quarter last year (4 quarters back)
SELECT Year, Quarter, Revenue,
LAG(Revenue, 4) OVER (ORDER BY Year, Quarter) AS SameQuarterLastYear,
Revenue - LAG(Revenue, 4) OVER (ORDER BY Year, Quarter) AS YoYChange
FROM QuarterlyRevenue;
```
### 4.4 Partitioned Offset Functions

```sql
-- Compare each product's price to its previous price (per product)
SELECT ProductID, Date, Price,
LAG(Price, 1) OVER (PARTITION BY ProductID ORDER BY Date) AS PrevPrice,
Price - LAG(Price, 1) OVER (PARTITION BY ProductID ORDER BY Date) AS PriceChange
FROM ProductPrices;
```
---

## Phase 5: Frame Specification - ROWS vs. RANGE

### 5.1 Frame Clause Syntax

```sql
{ ROWS | RANGE } BETWEEN <start> AND <end>

-- Start/End options:
-- UNBOUNDED PRECEDING: First row in partition
-- N PRECEDING: N rows before current
-- CURRENT ROW: Current row
-- N FOLLOWING: N rows after current
-- UNBOUNDED FOLLOWING: Last row in partition
```
### 5.2 ROWS - Physical Row Count

```sql
-- Sum of current row and 2 preceding rows (3-row window)
SELECT OrderDate, Amount,
SUM(Amount) OVER (ORDER BY OrderDate 
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Last3DaysTotal
FROM Orders;
```
**Output:**

OrderDate  | Amount | Last3DaysTotal
2024-01-01 | 100    | 100  -- Only 1 row
2024-01-02 | 150    | 250  -- 2 rows
2024-01-03 | 200    | 450  -- 3 rows (100+150+200)
2024-01-04 | 180    | 530  -- 3 rows (150+200+180)

### 5.3 RANGE - Logical Value Range

```sql
-- Sum all rows with OrderDate within 7 days before current row
SELECT OrderDate, Amount,
SUM(Amount) OVER (ORDER BY OrderDate 
RANGE BETWEEN INTERVAL 7 DAY PRECEDING AND CURRENT ROW) AS Last7DaysTotal
FROM Orders;
```
**Critical difference:**
- `ROWS`: Counts physical rows (always includes exactly N rows if available)
- `RANGE`: Includes all rows with values within specified range (can be 0 to many rows)

### 5.4 Default Frame Behavior

```sql
-- These are equivalent:
SELECT SUM(Amount) OVER (ORDER BY OrderDate) AS RunningTotal
FROM Orders;

SELECT SUM(Amount) OVER (ORDER BY OrderDate 
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Orders;

-- Without ORDER BY, default is entire partition:
SELECT SUM(Amount) OVER () AS GrandTotal
FROM Orders;
-- Equivalent to:
SELECT SUM(Amount) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS GrandTotal
FROM Orders;
```
### 5.5 Common Frame Patterns

```sql
-- Running total
SUM(Amount) OVER (ORDER BY Date ROWS UNBOUNDED PRECEDING)

-- Moving average (last 7 rows)
AVG(Amount) OVER (ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)

-- Centered moving average (3 before, current, 3 after)
AVG(Amount) OVER (ORDER BY Date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING)

-- Cumulative from start to current
SUM(Amount) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)

-- Entire partition (all rows)
SUM(Amount) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
```
---

## Phase 6: Advanced Patterns

### 6.1 Top N Per Group

```sql
-- Get top 3 highest-paid employees per department
WITH RankedEmployees AS (
SELECT EmployeeID, Name, Department, Salary,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank
FROM Employees
)
SELECT EmployeeID, Name, Department, Salary
FROM RankedEmployees
WHERE Rank <= 3;
```
### 6.2 Deduplication (Keep First/Last)

```sql
-- Remove duplicate orders, keep most recent per customer
WITH DeduplicatedOrders AS (
SELECT OrderID, CustomerID, OrderDate, Amount,
ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS RowNum
FROM Orders
)
DELETE FROM Orders
WHERE OrderID IN (
SELECT OrderID 
FROM DeduplicatedOrders 
WHERE RowNum > 1
);
```
### 6.3 Gap and Island Detection

```sql
-- Find consecutive date ranges (islands)
WITH DateGroups AS (
SELECT Date, 
DATEADD(DAY, -ROW_NUMBER() OVER (ORDER BY Date), Date) AS GroupID
FROM ActivityLog
)
SELECT MIN(Date) AS StartDate, 
MAX(Date) AS EndDate,
COUNT(*) AS ConsecutiveDays
FROM DateGroups
GROUP BY GroupID
ORDER BY StartDate;
```
**Example:**

Input dates: 2024-01-01, 2024-01-02, 2024-01-03, 2024-01-05, 2024-01-06

Output:
StartDate  | EndDate    | ConsecutiveDays
2024-01-01 | 2024-01-03 | 3
2024-01-05 | 2024-01-06 | 2

### 6.4 Conditional Aggregation with Window Functions

```sql
-- Running total of only positive values
SELECT Date, Amount,
SUM(CASE WHEN Amount > 0 THEN Amount ELSE 0 END) 
OVER (ORDER BY Date) AS RunningPositiveTotal
FROM Transactions;
```
### 6.5 Multiple Window Specifications

```sql
-- Use WINDOW clause to avoid repetition (SQL Server 2022+)
SELECT EmployeeID, Name, Salary,
AVG(Salary) OVER w AS DeptAvg,
MAX(Salary) OVER w AS DeptMax,
MIN(Salary) OVER w AS DeptMin
FROM Employees
WINDOW w AS (PARTITION BY Department);

**Pre-2022 workaround (repeat specification):**
sql
SELECT EmployeeID, Name, Salary,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvg,
MAX(Salary) OVER (PARTITION BY Department) AS DeptMax,
MIN(Salary) OVER (PARTITION BY Department) AS DeptMin
FROM Employees;
```
---

## Phase 7: Performance Optimization

### 7.1 Execution Plan Analysis

**Look for these operators:**
- **Window Spool:** Caches rows for window function processing (expected).
- **Sort:** Expensive if `ORDER BY` columns aren't indexed.
- **Segment:** Divides data for `PARTITION BY` (expected).

```sql
-- Enable execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Department, Salary,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank
FROM Employees;
```
### 7.2 Indexing Strategy

```sql
-- Create index matching PARTITION BY and ORDER BY columns
CREATE INDEX IX_Employees_Dept_Salary 
ON Employees (Department, Salary DESC);

-- This query will benefit:
SELECT Department, Salary,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Rank
FROM Employees;
```
**Rule:** Index columns in order: `PARTITION BY` columns first, then `ORDER BY` columns.

### 7.3 Avoid Repeated Window Specifications

```sql
-- BAD: Calculates same window function 3 times
SELECT EmployeeID, Name, Salary,
Salary - AVG(Salary) OVER (PARTITION BY Department) AS DiffFromAvg,
CAST(100.0 * Salary / AVG(Salary) OVER (PARTITION BY Department) AS DECIMAL(5,2)) AS PctOfAvg,
CASE WHEN Salary > AVG(Salary) OVER (PARTITION BY Department) THEN 'Above' ELSE 'Below' END AS Status
FROM Employees;

-- GOOD: Calculate once, reuse in outer query
WITH EmployeeStats AS (
SELECT EmployeeID, Name, Salary, Department,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvg
FROM Employees
)
SELECT EmployeeID, Name, Salary,
Salary - DeptAvg AS DiffFromAvg,
CAST(100.0 * Salary / DeptAvg AS DECIMAL(5,2)) AS PctOfAvg,
CASE WHEN Salary > DeptAvg THEN 'Above' ELSE 'Below' END AS Status
FROM EmployeeStats;
```
### 7.4 Frame Specification Performance

```sql
-- FAST: Default frame (optimized by SQL Server)
SELECT SUM(Amount) OVER (ORDER BY Date) AS RunningTotal
FROM Orders;

-- SLOWER: Explicit frame with FOLLOWING (requires buffering future rows)
SELECT SUM(Amount) OVER (ORDER BY Date 
ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING) AS CenteredTotal
FROM Orders;
```
### 7.5 Batch Mode vs. Row Mode

**SQL Server 2019+ enables batch mode for window functions on rowstore tables:**
```sql
-- Check execution plan for "Batch Mode" indicator
SELECT Department, Salary,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvg
FROM Employees
OPTION (USE HINT('DISALLOW_BATCH_MODE')); -- Force row mode for comparison
```
**Batch mode is faster for:**
- Large datasets (>100K rows)
- Multiple window functions in same query
- Aggregate window functions (SUM, AVG, COUNT)

---

## Phase 8: Common Pitfalls & Debugging

### 8.1 Pitfall: Using Window Functions in WHERE Clause

```sql
-- WRONG: Window functions not allowed in WHERE
SELECT EmployeeID, Name, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS Rank
FROM Employees
WHERE ROW_NUMBER() OVER (ORDER BY Salary DESC) <= 10; -- ERROR

-- CORRECT: Use CTE or subquery
WITH RankedEmployees AS (
SELECT EmployeeID, Name, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) AS Rank
FROM Employees
)
SELECT EmployeeID, Name, Salary
FROM RankedEmployees
WHERE Rank <= 10;
```
### 8.2 Pitfall: Forgetting ORDER BY in Frame Specification

```sql
-- WRONG: Frame clause requires ORDER BY
SELECT SUM(Amount) OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Total
FROM Orders; -- ERROR

-- CORRECT: Add ORDER BY
SELECT SUM(Amount) OVER (ORDER BY OrderDate 
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Total
FROM Orders;
```
### 8.3 Pitfall: NULL Handling in ORDER BY

```sql
-- NULLs sort first by default (ASC) or last (DESC)
SELECT Name, Salary,
ROW_NUMBER() OVER (ORDER BY Salary) AS Rank
FROM Employees;

-- Explicit NULL handling
SELECT Name, Salary,
ROW_NUMBER() OVER (ORDER BY ISNULL(Salary, 0)) AS Rank
FROM Employees;
```
### 8.4 Pitfall: Mixing Aggregate and Window Functions

```sql
-- WRONG: Can't mix GROUP BY aggregates with window functions directly
SELECT Department, 
COUNT(*) AS EmpCount,
AVG(Salary) OVER (PARTITION BY Department) AS DeptAvg -- ERROR
FROM Employees
GROUP BY Department;

-- CORRECT: Use subquery or CTE
WITH DeptCounts AS (
SELECT Department, COUNT(*) AS EmpCount
FROM Employees
GROUP BY Department
)
SELECT dc.Department, dc.EmpCount,
AVG(e.Salary) OVER (PARTITION BY e.Department) AS DeptAvg
FROM DeptCounts dc
INNER JOIN Employees e ON dc.Department = e.Department;
```
### 8.5 Debugging Technique: Isolate Window Specification

```sql
-- Test window specification separately
SELECT EmployeeID, Name, Department, Salary,
-- Add these debug columns
COUNT(*) OVER (PARTITION BY Department) AS RowsInPartition,
ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Salary) AS RowInPartition
FROM Employees
ORDER BY Department, Salary;
```
---

## Phase 9: Real-World Use Cases

### 9.1 Sales Analysis Dashboard

```sql
-- Comprehensive sales metrics
WITH SalesMetrics AS (
SELECT 
OrderDate,
Amount,
-- Running total
SUM(Amount) OVER (ORDER BY OrderDate) AS RunningTotal,
-- 7-day moving average
AVG(Amount) OVER (ORDER BY OrderDate 
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS MovingAvg7Day,
-- Day-over-day change
Amount - LAG(Amount, 1) OVER (ORDER BY OrderDate) AS DayOverDayChange,
-- Percent of monthly total
CAST(100.0 * Amount / SUM(Amount) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) 
AS DECIMAL(5,2)) AS PctOfMonthTotal,
-- Rank within month
DENSE_RANK() OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate) 
ORDER BY Amount DESC) AS RankInMonth
FROM DailySales
)
SELECT * FROM SalesMetrics
ORDER BY OrderDate;
```
### 9.2 Customer Cohort Analysis

```sql
-- Analyze customer retention by signup cohort
WITH FirstPurchase AS (
SELECT CustomerID,
MIN(OrderDate) AS FirstOrderDate,
DATEFROMPARTS(YEAR(MIN(OrderDate)), MONTH(MIN(OrderDate)), 1) AS Cohort
FROM Orders
GROUP BY CustomerID
),
MonthlyActivity AS (
SELECT 
fp.Cohort,
DATEDIFF(MONTH, fp.FirstOrderDate, o.OrderDate) AS MonthsSinceFirst,
COUNT(DISTINCT o.CustomerID) AS ActiveCustomers
FROM FirstPurchase fp
INNER JOIN Orders o ON fp.CustomerID = o.CustomerID
GROUP BY fp.Cohort, DATEDIFF(MONTH, fp.FirstOrderDate, o.OrderDate)
)
SELECT 
Cohort,
MonthsSinceFirst,
ActiveCustomers,
FIRST_VALUE(ActiveCustomers) OVER (PARTITION BY Cohort ORDER BY MonthsSinceFirst) AS CohortSize,
CAST(100.0 * ActiveCustomers / 
FIRST_VALUE(ActiveCustomers) OVER (PARTITION BY Cohort ORDER BY MonthsSinceFirst) 
AS DECIMAL(5,2)) AS RetentionRate
FROM MonthlyActivity
ORDER BY Cohort, MonthsSinceFirst;
```
### 9.3 Inventory Reorder Point Calculation

```sql
-- Calculate when to reorder based on usage trends
SELECT 
ProductID,
Date,
QuantityOnHand,
-- 30-day average daily usage
AVG(DailyUsage) OVER (PARTITION BY ProductID 
ORDER BY Date 
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS AvgDailyUsage,
-- Days until stockout at current usage rate
CASE 
WHEN AVG(DailyUsage) OVER (PARTITION BY ProductID 
ORDER BY Date 
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) > 0
THEN QuantityOnHand / AVG(DailyUsage) OVER (PARTITION BY ProductID 
ORDER BY Date 
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)
ELSE NULL
END AS DaysUntilStockout,
-- Reorder flag
CASE 
WHEN QuantityOnHand / NULLIF(AVG(DailyUsage) OVER (PARTITION BY ProductID 
ORDER BY Date 
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 0) < 14
THEN 'REORDER NOW'
ELSE 'OK'
END AS ReorderStatus
FROM InventoryLog;
```
---

## Phase 10: Action Plan for Implementation

### Step 1: Identify Opportunities
Audit existing queries for these patterns:
- Self-joins for previous/next row comparisons → Replace with `LAG`/`LEAD`
- Correlated subqueries for running totals → Replace with window functions
- Multiple `GROUP BY` queries joined together → Combine with window functions

### Step 2: Performance Baseline
Before refactoring:
```sql
-- Capture baseline metrics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Run existing query
<your_current_query>

-- Note: Logical reads, CPU time, elapsed time
```
### Step 3: Refactor and Compare
```sql
-- Run new query with window functions
<your_refactored_query>

-- Compare metrics
-- Expected: Fewer logical reads, similar or better CPU time
```
### Step 4: Index Optimization
```sql
-- Create indexes for window function columns
CREATE INDEX IX_TableName_PartitionOrder 
ON TableName (PartitionColumn, OrderColumn)
INCLUDE (OtherColumns);
```
### Step 5: Testing Checklist
- [ ] Verify results match original query (use `EXCEPT` to find differences)
- [ ] Test with NULL values in partition/order columns
- [ ] Test with empty partitions
- [ ] Test with single-row partitions
- [ ] Verify performance with production data volumes

---

## Final Challenge: Mastery Test

**Scenario:** You have a `Transactions` table with columns: `AccountID`, `TransactionDate`, `Amount`, `Type` (Debit/Credit).

**Task:** Write a query that shows:
1. Running balance per account (credits add, debits subtract)
2. 30-day moving average of transaction amounts
3. Rank of each transaction by amount within its account
4. Flag transactions that are >2 standard deviations from account average

**Solution:**

```sql
WITH TransactionMetrics AS (
SELECT 
AccountID,
TransactionDate,
Amount,
Type,
-- Running balance
SUM(CASE WHEN Type = 'Credit' THEN Amount ELSE -Amount END) 
OVER (PARTITION BY AccountID ORDER BY TransactionDate 
ROWS UNBOUNDED PRECEDING) AS RunningBalance,
-- 30-day moving average
AVG(Amount) 
OVER (PARTITION BY AccountID ORDER BY TransactionDate 
ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS MovingAvg30Day,
-- Rank by amount within account
DENSE_RANK() 
OVER (PARTITION BY AccountID ORDER BY Amount DESC) AS AmountRank,
-- Account average and standard deviation
AVG(Amount) OVER (PARTITION BY AccountID) AS AccountAvg,
STDEV(Amount) OVER (PARTITION BY AccountID) AS AccountStdDev
FROM Transactions
)
SELECT 
AccountID,
TransactionDate,
Amount,
Type,
Runnin
```
