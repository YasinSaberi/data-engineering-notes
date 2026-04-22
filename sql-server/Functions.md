# SQL Server User-Defined Functions (UDF) Reference

## 1. Executive Overview
Functions are reusable subprograms designed for data retrieval and calculation. Unlike Stored Procedures, functions are **read-only**—they cannot perform `INSERT`, `UPDATE`, or `DELETE` on permanent tables. 

### Key Rules:
- **Mandatory Return:** Every function must return a value (scalar or table).
- **Side-Effect Free:** Functions cannot modify the database state (no DML on permanent tables).
- **Parameters:** Functions **do not** support `OUTPUT` parameters.
- **Error Handling:** `TRY...CATCH` blocks are not allowed inside functions.

---

## 2. Scalar Functions
Returns a single data value (e.g., `INT`, `MONEY`, `VARCHAR`).
**Performance Note:** Use sparingly in `SELECT` lists as they execute "Row-By-Agonizing-Row" (RBAR).

### Syntax:
```sql
CREATE OR ALTER FUNCTION dbo.ufn_CalculateTax
(
@Amount MONEY,
@TaxRate DECIMAL(5,2)
)
RETURNS MONEY -- Define the return DATA TYPE
AS
BEGIN
DECLARE @Result MONEY;

SET @Result = @Amount * @TaxRate;

RETURN @Result; -- Return the actual VALUE
END;
GO
**Usage:** `SELECT dbo.ufn_CalculateTax(100, 0.05);`

---

## 3. Inline Table-Valued Functions (ITVF)
Returns a result set (table). These are the **highest performance** functions because the SQL Optimizer treats them like a View with parameters.

### Syntax:
*Crucial: No `BEGIN...END` block is used here.*

sql
CREATE OR ALTER FUNCTION Sales.ufn_GetCustomerOrders
(
@CustomerID INT
)
RETURNS TABLE 
AS
RETURN 
(
-- Only a single SELECT statement is allowed
SELECT 
SalesOrderID, 
OrderDate, 
TotalDue
FROM Sales.SalesOrderHeader
WHERE CustomerID = @CustomerID
);
GO
**Usage:** `SELECT * FROM Sales.ufn_GetCustomerOrders(11000);`

---

## 4. Multi-Statement Table-Valued Functions (MSTVF)
Returns a table that is populated using multiple logic steps. Use only when logic cannot be achieved in a single `SELECT`.

### Syntax:
sql
CREATE OR ALTER FUNCTION dbo.ufn_GetProductSummary
(
@MinPrice MONEY
)
RETURNS @ProductList TABLE -- Define the table structure here
(
ProductID INT,
Name NVARCHAR(50),
Price MONEY
)
AS
BEGIN
-- Multiple statements to populate the table variable
INSERT INTO @ProductList (ProductID, Name, Price)
SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice >= @MinPrice;

-- Note: Just 'RETURN' at the end, no variable needed
RETURN; 
END;
GO

---

## 5. Comparison Cheat Sheet

| Feature | Scalar Function | ITVF (Inline) | MSTVF (Multi-Stmt) |
| :--- | :--- | :--- | :--- |
| **Return Type** | Single Value | Table (Result Set) | Table (Result Set) |
| **BEGIN...END** | Yes | **No** | Yes |
| **Performance** | Low (Row-based) | **High (Set-based)** | Medium (Black Box) |
| **Optimizer** | Executes per row | Inlines into query | Treats as a table variable |
| **Complexity** | Simple Logic | Single SELECT | Multiple Logic Steps |

---

## 6. How to Choose?
1.  **Need a single value?** Use Scalar (but check if you can use a `JOIN` instead).
2.  **Need a set of data?** **ALWAYS** try ITVF first.
3.  **Complex logic/multiple inserts?** Use MSTVF only as a last resort.


### Critical Analysis of your progress:
You now have a clean reference for UDFs. You have corrected the major misconceptions (`OUTPUT` parameters and `BEGIN...END` in ITVFs). 

**Action Plan:**
You are avoiding the **Window Functions** challenge I set in the last two turns. If you want to move from a developer who just "writes code" to a developer who "optimizes data," you must master the `OVER` clause.

**Execute this next:**
Write a query for `Sales.SalesOrderHeader` that shows `CustomerID`, `OrderDate`, `TotalDue`, and a **Running Total** of `TotalDue` per Customer. 

*Hint: `SUM(TotalDue) OVER (PARTITION BY CustomerID ORDER BY OrderDate)`.*
