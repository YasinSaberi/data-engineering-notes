# SQL Server User-Defined Functions (UDF)

## 1. Overview
Functions are reusable routines that perform calculations and return a value. Unlike Stored Procedures, Functions are designed to be **read-only** and can be embedded directly into `SELECT`, `WHERE`, and `JOIN` clauses.

### Key Restrictions:
* **No Side Effects:** You cannot perform `INSERT`, `UPDATE`, or `DELETE` on permanent tables.
* **No Error Handling:** `TRY...CATCH` blocks are prohibited.
* **No Temp Tables:** Only Table Variables (`@Table`) are allowed; Temporary Tables (`#Table`) are not.

---

## 2. Scalar Functions
Returns a **single value** (e.g., INT, VARCHAR, MONEY).
**Performance Note:** Use sparingly. When used in a SELECT list, they execute once for every row (RBAR), which kills performance on large datasets.
```sql
CREATE OR ALTER FUNCTION dbo.ufn_GetDiscountedPrice
(
@Price MONEY,
@DiscountRate DECIMAL(4,2)
)
RETURNS MONEY -- Declare return DATA TYPE
AS
BEGIN
DECLARE @Result MONEY;

SET @Result = @Price * (1 - @DiscountRate);

RETURN @Result; -- Return the actual VALUE
END;
GO

```

## 3. Inline Table-Valued Functions (ITVF)
Returns a **result set**. 
**Performance Note:** These are the most efficient functions. SQL Server treats them like a View with parameters, allowing for high-performance execution plans.

```sql
CREATE OR ALTER FUNCTION Sales.ufn_GetCustomerOrders
(
@CustomerID INT
)
RETURNS TABLE -- Declare that a table is returned
AS
RETURN 
(
-- NO BEGIN/END block allowed. 
-- Must be a single RETURN statement containing one SELECT query.
SELECT SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE CustomerID = @CustomerID
);
GO

```

## 4. Multi-Statement Table-Valued Functions (MSTVF)
Returns a **result set** populated via multiple logic steps.
**Performance Note:** These are "Black Boxes" to the Query Optimizer. They often cause performance degradation because the optimizer cannot accurately estimate the row count.

```sql
CREATE OR ALTER FUNCTION dbo.ufn_CategorizedProducts
(
@PriceThreshold MONEY
)
RETURNS @ProductTable TABLE -- Define the table structure to be returned
(
ProductID INT,
PriceStatus NVARCHAR(20)
)
AS
BEGIN
-- Logic 1: High value products
INSERT INTO @ProductTable (ProductID, PriceStatus)
SELECT ProductID, 'Expensive'
FROM Production.Product
WHERE ListPrice > @PriceThreshold;

-- Logic 2: Low value products
INSERT INTO @ProductTable (ProductID, PriceStatus)
SELECT ProductID, 'Cheap'
FROM Production.Product
WHERE ListPrice <= @PriceThreshold;

RETURN; -- Returns the table variable defined above
END;
GO

```

## 5. Comparison Matrix

| Feature | Scalar Function | Inline TVF (ITVF) | Multi-Statement TVF (MSTVF) |
| :--- | :--- | :--- | :--- |
| **Returns** | Single Value | Result Set (Table) | Result Set (Table) |
| **Logic Block** | `BEGIN...END` | **Single SELECT** | `BEGIN...END` |
| **Performance** | Low (RBAR) | **High** | Medium/Low |
| **Use Case** | Calculations | Reusable Queries | Complex Data Processing |
