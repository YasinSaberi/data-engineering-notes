# SQL Server Stored Procedures (SP)

A **Stored Procedure** is a pre-compiled block of T-SQL code stored on the database server. It acts like a "Database Method" that can be executed multiple times.

### Key Features & Benefits
*   **Performance:** SPs reduce network traffic because only the procedure name and parameters are sent over the network, not the entire query text. They also promote better **Execution Plan Reuse**.
*   **Security:** 
    *   **SQL Injection Prevention:** By using parameters, SPs inherently protect the database from malicious input.
    *   **Access Control:** You can grant a user permission to execute an SP without giving them direct access to the underlying tables.
*   **Modularity:** You can write the logic once and call it from different applications or scripts.

### Stored Procedures vs. Functions
| Feature | Stored Procedure | Function |
| :--- | :--- | :--- |
| **Data Modification** | Can perform `INSERT`, `UPDATE`, `DELETE` (DML). | Generally read-only; cannot change database state. |
| **Return Values** | Can return multiple result sets, output parameters, or a status code. | Must return a single value or a **Table** (Table-Valued Functions). |
| **Execution** | Called using `EXEC` or `EXECUTE`. | Used within a `SELECT`, `WHERE`, or `JOIN` clause. |

### Best Practices
1.  **`SET NOCOUNT ON;`**: Always include this at the beginning of the body. It prevents SQL Server from sending "x rows affected" messages to the client, which reduces network overhead.
2.  **`CREATE OR ALTER`**: Use this syntax to modify existing procedures. It ensures that existing **Permissions** (Grants) and dependencies are not lost (unlike `DROP` and `CREATE`).
3.  **Naming Convention**: Avoid using `sp_` as a prefix, as SQL Server looks in the `master` database first for those, causing a slight performance hit.

---

### Standard Syntax
```sql
CREATE OR ALTER PROCEDURE [SchemaName].[ProcedureName]
-- Input Parameters
@InputParam1 DataType,
@InputParam2 DataType = DefaultValue, -- Parameter with default value

-- Output Parameter
@OutputParam DataType OUTPUT 
AS
BEGIN
-- 1. Performance optimization
SET NOCOUNT ON;

-- 2. Procedure Body
SELECT @OutputParam = Column 
FROM [SchemaName].[TableName]
WHERE Id = @InputParam1;

-- Additional Logic (Insert/Update/Delete)

END
```
### SCOPE_IDENTITY():
A system function that return the last generated identity value in the present scope.

### Usage example for AdvantureWorks2012
```sql
CREATE OR ALTER PROCEDURE Production.uspCreateProductReview
    @comments NVARCHAR(3850), 
    @rating INT,
    @emailAddress NVARCHAR(50), 
    @reviewerName NVARCHAR(50), 
    @productID INT,
    @reviewID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Production.ProductReview (
        Comments,
        Rating,
        EmailAddress,
        ReviewDate,        
        ReviewerName,
        ProductID
    )
    VALUES (
        @comments,
        @rating,
        @emailAddress,
        GETDATE(),     
        @reviewerName,
        @productID
    );

    SET @reviewID = SCOPE_IDENTITY();
END;
```
