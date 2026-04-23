# SQL Server Mastery: CTEs and Recursive CTEs - Zero to Hero

## Executive Summary

Common Table Expressions (CTEs) are temporary named result sets scoped to a single query. **Critical misconception:** CTEs are NOT materialized or cached—SQL Server treats them as inline views, potentially re-executing logic on every reference. Use CTEs for readability and single-reference scenarios; switch to temp tables when performance matters. Recursive CTEs are the only declarative way to traverse hierarchical data in SQL Server, but they carry infinite-loop risk and require explicit safeguards (`MAXRECURSION`). **Bottom line:** CTEs are a readability tool, not a performance optimization.

---

## Phase 1: Standard CTEs - Foundation

### 1.1 Core Syntax
```sql
WITH CTE_Name (Column1, Column2) AS (
-- Inner query: defines the result set
SELECT Col1, Col2 
FROM Table 
WHERE Condition = 1
)
-- Outer query: consumes the CTE
SELECT * FROM CTE_Name;

**Key rules:**
- CTE must be immediately followed by the consuming query (no `GO` statements between).
- Column aliases can be defined in the `WITH` clause or inside the `SELECT`.
- Multiple CTEs can be chained with commas (no repeated `WITH` keyword).
```
### 1.2 Multiple CTEs in One Query

```sql
WITH Sales_CTE AS (
SELECT ProductID, SUM(Quantity) AS TotalSold
FROM Orders
GROUP BY ProductID
),
Inventory_CTE AS (
SELECT ProductID, StockLevel
FROM Warehouse
)
SELECT s.ProductID, s.TotalSold, i.StockLevel
FROM Sales_CTE s
INNER JOIN Inventory_CTE i ON s.ProductID = i.ProductID;
```
### 1.3 When to Use CTEs

**Valid use cases:**
- Breaking down complex queries into logical steps for maintainability.
- Replacing views when you lack `CREATE VIEW` permissions.
- Simplifying queries with multiple references to the same subquery logic (but see Phase 2 for performance caveats).

**Anti-patterns:**
- Using CTEs to "optimize" performance (they don't).
- Assuming CTEs persist data across multiple statements (they don't).

---

## Phase 2: Performance Reality - Critical Analysis

### 2.1 The Materialization Myth

**What developers think:**
```sql
WITH Expensive_CTE AS (
SELECT * FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE YEAR(OrderDate) = 2024
)
SELECT COUNT(*) FROM Expensive_CTE
UNION ALL
SELECT AVG(TotalAmount) FROM Expensive_CTE;
```
"The CTE runs once, then both queries read from the cached result."

**What actually happens:**
SQL Server may execute the CTE's join logic **twice**—once for each reference. Check the execution plan: if you see the same operators duplicated, the CTE is being re-evaluated.

### 2.2 CTE vs. Temp Table vs. Table Variable

| Feature | CTE | Temp Table (#Table) | Table Variable (@Table) |
|---------|-----|---------------------|------------------------|
| **Scope** | Single query | Session | Batch/procedure |
| **Statistics** | No | Yes | No (limited in 2019+) |
| **Indexes** | No | Yes | Yes (inline only) |
| **Re-execution risk** | High | None | None |
| **Best for** | Readability, single use | Large datasets, multiple refs | Small datasets (<1000 rows) |

### 2.3 Decision Framework

```sql
-- BAD: CTE referenced 3 times with heavy aggregation
WITH Sales_Summary AS (
SELECT CustomerID, SUM(Amount) AS Total, COUNT(*) AS Orders
FROM Sales
GROUP BY CustomerID
)
SELECT * FROM Sales_Summary WHERE Total > 10000
UNION ALL
SELECT * FROM Sales_Summary WHERE Orders > 50
UNION ALL
SELECT * FROM Sales_Summary WHERE Total < 1000;

-- GOOD: Use temp table for multiple references
SELECT CustomerID, SUM(Amount) AS Total, COUNT(*) AS Orders
INTO #Sales_Summary
FROM Sales
GROUP BY CustomerID;

SELECT * FROM #Sales_Summary WHERE Total > 10000;
SELECT * FROM #Sales_Summary WHERE Orders > 50;
SELECT * FROM #Sales_Summary WHERE Total < 1000;

DROP TABLE #Sales_Summary;
```
**Action:** Always check the execution plan. Look for duplicated operators (scans, joins, aggregations) when a CTE is referenced multiple times.

---

## Phase 3: Recursive CTEs - Hierarchical Data

### 3.1 The Three-Part Structure

1. **Anchor member:** Base case (starting point).
2. **Recursive member:** Self-referencing query that builds on the previous iteration.
3. **Termination:** Implicit—recursion stops when the recursive member returns no rows.

### 3.2 Example 1: Employee Hierarchy

```sql
-- Table structure
CREATE TABLE Employees (
EmployeeID INT PRIMARY KEY,
Name NVARCHAR(100),
ManagerID INT NULL
);

-- Sample data
INSERT INTO Employees VALUES 
(1, 'Alice CEO', NULL),
(2, 'Bob VP', 1),
(3, 'Carol VP', 1),
(4, 'Dave Manager', 2),
(5, 'Eve Manager', 2),
(6, 'Frank Employee', 4);

-- Recursive CTE
WITH OrgHierarchy AS (
-- Anchor: Top-level employees (no manager)
SELECT EmployeeID, Name, ManagerID, 1 AS Level, 
CAST(Name AS NVARCHAR(1000)) AS Path
FROM Employees
WHERE ManagerID IS NULL

UNION ALL

-- Recursive: Join employees to their managers
SELECT e.EmployeeID, e.Name, e.ManagerID, oh.Level + 1,
CAST(oh.Path + ' > ' + e.Name AS NVARCHAR(1000))
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT EmployeeID, Name, Level, Path
FROM OrgHierarchy
ORDER BY Level, Name;
```
**Output:**

EmployeeID | Name          | Level | Path
-----------|---------------|-------|---------------------------
1          | Alice CEO     | 1     | Alice CEO
2          | Bob VP        | 2     | Alice CEO > Bob VP
3          | Carol VP      | 2     | Alice CEO > Carol VP
4          | Dave Manager  | 3     | Alice CEO > Bob VP > Dave Manager
5          | Eve Manager   | 3     | Alice CEO > Bob VP > Eve Manager
6          | Frank Employee| 4     | Alice CEO > Bob VP > Dave Manager > Frank Employee

### 3.3 Example 2: Date Series Generation (No Base Table)

```sql
-- Generate all dates in May 2024
WITH DateSeries AS (
-- Anchor: First day of the month
SELECT CAST('2024-05-01' AS DATE) AS DateValue

UNION ALL

-- Recursive: Add one day until end of month
SELECT DATEADD(DAY, 1, DateValue)
FROM DateSeries
WHERE DateValue < '2024-05-31'
)
SELECT DateValue, DATENAME(WEEKDAY, DateValue) AS DayName
FROM DateSeries
OPTION (MAXRECURSION 31);
```
### 3.4 Example 3: Bill of Materials (BOM)

```sql
CREATE TABLE Parts (
PartID INT,
PartName NVARCHAR(50),
ParentPartID INT NULL,
Quantity INT
);

INSERT INTO Parts VALUES
(1, 'Bicycle', NULL, 1),
(2, 'Frame', 1, 1),
(3, 'Wheel', 1, 2),
(4, 'Tire', 3, 1),
(5, 'Spoke', 3, 36);

WITH BOM AS (
-- Anchor: Top-level product
SELECT PartID, PartName, ParentPartID, Quantity, 0 AS Level
FROM Parts
WHERE ParentPartID IS NULL

UNION ALL

-- Recursive: Explode sub-components
SELECT p.PartID, p.PartName, p.ParentPartID, 
p.Quantity * b.Quantity AS TotalQuantity, 
b.Level + 1
FROM Parts p
INNER JOIN BOM b ON p.ParentPartID = b.PartID
)
SELECT REPLICATE('  ', Level) + PartName AS Component, TotalQuantity
FROM BOM
ORDER BY Level, PartID;
```
---

## Phase 4: Risk Management & Guardrails

### 4.1 The Infinite Loop Problem

**Scenario:** Circular reference in data.

```sql
-- BAD DATA: Employee 2 reports to Employee 4, who reports to Employee 2
UPDATE Employees SET ManagerID = 4 WHERE EmployeeID = 2;
UPDATE Employees SET ManagerID = 2 WHERE EmployeeID = 4;

-- This query will run forever (or until MAXRECURSION limit)
WITH OrgHierarchy AS (
SELECT EmployeeID, Name, ManagerID, 1 AS Level
FROM Employees
WHERE EmployeeID = 2

UNION ALL

SELECT e.EmployeeID, e.Name, e.ManagerID, oh.Level + 1
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT * FROM OrgHierarchy
OPTION (MAXRECURSION 10); -- Fails after 10 iterations
```
**Error message:**

Msg 530: The statement terminated. The maximum recursion 10 has been exhausted before statement completion.

### 4.2 Detecting Circular References

```sql
WITH OrgHierarchy AS (
SELECT EmployeeID, Name, ManagerID, 
CAST(EmployeeID AS NVARCHAR(1000)) AS Path,
1 AS Level
FROM Employees
WHERE ManagerID IS NULL

UNION ALL

SELECT e.EmployeeID, e.Name, e.ManagerID,
oh.Path + '>' + CAST(e.EmployeeID AS NVARCHAR(10)),
oh.Level + 1
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
WHERE oh.Path NOT LIKE '%>' + CAST(e.EmployeeID AS NVARCHAR(10)) + '>%' -- Prevent cycles
)
SELECT * FROM OrgHierarchy;
```
### 4.3 MAXRECURSION Options

```sql
OPTION (MAXRECURSION 0)    -- Unlimited (dangerous)
OPTION (MAXRECURSION 100)  -- Default if not specified
OPTION (MAXRECURSION 500)  -- Custom limit
```
**Best practice:** Set `MAXRECURSION` to 2× your expected maximum depth. For org charts with 10 levels, use `MAXRECURSION 20`.

### 4.4 Performance Considerations

**Execution plan indicators:**
- **Table Spool / Index Spool:** SQL Server is caching intermediate results.
- **Nested Loops with high iteration count:** Each recursion level is a loop iteration.

**Optimization strategies:**
1. **Add indexes on join columns:** Index `ManagerID` in the employee hierarchy example.
2. **Limit recursion depth early:** Use `WHERE Level < 10` in the recursive member.
3. **Consider alternative approaches:** For very deep hierarchies (>100 levels), use `HIERARCHYID` data type or pre-computed path columns.

---

## Phase 5: Advanced Patterns

### 5.1 Aggregating Across Hierarchy Levels

```sql
-- Calculate total salary cost per manager (including all subordinates)
WITH OrgHierarchy AS (
SELECT EmployeeID, Name, ManagerID, Salary, 1 AS Level
FROM Employees
WHERE ManagerID IS NULL

UNION ALL

SELECT e.EmployeeID, e.Name, e.ManagerID, e.Salary, oh.Level + 1
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT ManagerID, SUM(Salary) AS TotalTeamCost
FROM OrgHierarchy
GROUP BY ManagerID;
```
### 5.2 Finding Leaf Nodes (Employees with No Subordinates)

```sql
WITH OrgHierarchy AS (
SELECT EmployeeID, Name, ManagerID
FROM Employees
WHERE ManagerID IS NULL

UNION ALL

SELECT e.EmployeeID, e.Name, e.ManagerID
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT oh.EmployeeID, oh.Name
FROM OrgHierarchy oh
LEFT JOIN Employees e ON oh.EmployeeID = e.ManagerID
WHERE e.EmployeeID IS NULL; -- No one reports to this employee
```
### 5.3 Combining Multiple CTEs with Recursion

```sql
WITH Sales_CTE AS (
SELECT CustomerID, SUM(Amount) AS TotalSales
FROM Orders
GROUP BY CustomerID
),
CustomerHierarchy AS (
-- Anchor: Top-level customers
SELECT CustomerID, ParentCustomerID, 1 AS Level
FROM Customers
WHERE ParentCustomerID IS NULL

UNION ALL

-- Recursive: Child customers
SELECT c.CustomerID, c.ParentCustomerID, ch.Level + 1
FROM Customers c
INNER JOIN CustomerHierarchy ch ON c.ParentCustomerID = ch.CustomerID
)
SELECT ch.CustomerID, ch.Level, ISNULL(s.TotalSales, 0) AS Sales
FROM CustomerHierarchy ch
LEFT JOIN Sales_CTE s ON ch.CustomerID = s.CustomerID
ORDER BY ch.Level, ch.CustomerID;
```
---

## Phase 6: Common Pitfalls & Debugging

### 6.1 Pitfall: Missing UNION ALL

```sql
-- WRONG: Using UNION instead of UNION ALL
WITH Numbers AS (
SELECT 1 AS N
UNION  -- This removes duplicates (expensive and wrong)
SELECT N + 1 FROM Numbers WHERE N < 10
)
SELECT * FROM Numbers;

-- CORRECT: Always use UNION ALL in recursive CTEs
WITH Numbers AS (
SELECT 1 AS N
UNION ALL
SELECT N + 1 FROM Numbers WHERE N < 10
)
SELECT * FROM Numbers;
```
### 6.2 Pitfall: Data Type Truncation

```sql
-- BAD: Path column too small
WITH OrgHierarchy AS (
SELECT EmployeeID, Name, CAST(Name AS NVARCHAR(50)) AS Path
FROM Employees
WHERE ManagerID IS NULL

UNION ALL

SELECT e.EmployeeID, e.Name, 
CAST(oh.Path + ' > ' + e.Name AS NVARCHAR(50)) -- Truncates deep paths
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
)
SELECT * FROM OrgHierarchy;

-- GOOD: Use sufficient size
CAST(oh.Path + ' > ' + e.Name AS NVARCHAR(4000))
```
### 6.3 Debugging Technique: Add Level Limits

```sql
-- Add WHERE clause to test first few levels
WITH OrgHierarchy AS (
SELECT EmployeeID, Name, ManagerID, 1 AS Level
FROM Employees
WHERE ManagerID IS NULL

UNION ALL

SELECT e.EmployeeID, e.Name, e.ManagerID, oh.Level + 1
FROM Employees e
INNER JOIN OrgHierarchy oh ON e.ManagerID = oh.EmployeeID
WHERE oh.Level < 3 -- Test with small depth first
)
SELECT * FROM OrgHierarchy;
```
---

## Action Plan for Implementation

### Step 1: Audit Existing Queries
- Identify nested subqueries (3+ levels deep) → Refactor to CTEs for readability.
- Find CTEs referenced multiple times → Benchmark against temp tables.

### Step 2: Validate Hierarchical Data
Before writing recursive CTEs:
sql
-- Check for circular references
SELECT e1.EmployeeID, e1.ManagerID
FROM Employees e1
INNER JOIN Employees e2 ON e1.ManagerID = e2.EmployeeID
INNER JOIN Employees e3 ON e2.ManagerID = e3.EmployeeID
WHERE e3.ManagerID = e1.EmployeeID;

### Step 3: Performance Testing Checklist
- [ ] Run query with `SET STATISTICS IO ON` and `SET STATISTICS TIME ON`.
- [ ] Check execution plan for duplicate operators when CTE is referenced multiple times.
- [ ] Compare CTE vs. temp table for queries with >10,000 rows.
- [ ] Verify indexes exist on join columns used in recursive member.

### Step 4: Set Standards
- **Always** use `MAXRECURSION` in recursive CTEs (default: 100).
- **Never** use `MAXRECURSION 0` in production without explicit approval.
- **Document** expected hierarchy depth in comments.

---

## Final Challenge: Mastery Test

Write a recursive CTE that:
1. Generates a Fibonacci sequence up to the 20th number.
2. Stops when the value exceeds 10,000.
3. Includes a running sum column.

**Solution:**

```sql
WITH Fibonacci AS (
-- Anchor: First two Fibonacci numbers
SELECT 1 AS N, 0 AS Fib, 1 AS NextFib, 0 AS RunningSum

UNION ALL

-- Recursive: Calculate next Fibonacci number
SELECT N + 1, NextFib, Fib + NextFib, RunningSum + NextFib
FROM Fibonacci
WHERE N < 20 AND NextFib <= 10000
)
SELECT N AS Position, Fib AS FibonacciNumber, RunningSum
FROM Fibonacci
OPTION (MAXRECURSION 20);
```
**Expected output:**

Position | FibonacciNumber | RunningSum
---------|-----------------|------------
1        | 0               | 0
2        | 1               | 1
3        | 1               | 2
4        | 2               | 4
5        | 3               | 7
...

---

## Critical Takeaways

1. **CTEs are not performance tools**—they're readability tools. Use temp tables for heavy lifting.
2. **Recursive CTEs are the only declarative way** to handle hierarchies in SQL Server, but require safeguards.
3. **Always set `MAXRECURSION`** to prevent runaway queries.
4. **Check execution plans**—if you see duplicated operators, your CTE is being re-executed.
5. **Validate data integrity** before recursion—circular references will crash your query.
