# AdventureWorks SQL Server Mastery Exam

**Coverage:** Basic SQL • Joins • Window Functions • CTEs & Recursive CTEs • Stored Procedures • Functions • Transactions • Isolation Levels • Indexing • MERGE • Execution Plans • Real‑world Scenarios

---

## Section 1 — Fundamentals (Easy → Intermediate)

### 1. Return the total number of products in the database.
```sql
-- Write your query here

### 2. List all customers with their email address and full name, sorted alphabetically by last name.

sql
-- Write your query here

### 3. Retrieve all products that have no associated sales order details.

sql
-- Write your query here

### 4. Show the number of orders per year.

sql
-- Write your query here

### 5. For each product category, return the top 3 products by list price.

sql
-- Write your query here

---

## Section 2 — Joins & Multi‑Table Scenarios (Intermediate)

### 6. List all employees and their managers (full hierarchy, but not recursive yet).

sql
-- Write your query here

### 7. Return all customers whose most recent order was more than 6 months ago.

sql
-- Write your query here

### 8. Find products that are supplied by multiple vendors and list how many vendors each has.

sql
-- Write your query here

### 9. Return all sales orders where the same customer placed more than one order on the same day.

sql
-- Write your query here

### 10. Identify sales representatives whose sales YTD are below their territory average.

sql
-- Write your query here

---

## Section 3 — Window Functions (Intermediate → Hard)

### 11. For each salesperson, calculate the running total of their sales by date.

sql
-- Write your query here

### 12. Rank products by revenue within each category.

sql
-- Write your query here

### 13. Calculate 7‑day moving average sales (order amount) per territory.

sql
-- Write your query here

### 14. For each product, show the difference between its price and the average price of its subcategory.

sql
-- Write your query here

### 15. Detect price anomalies: products priced more than 2 standard deviations above their category mean.

sql
-- Write your query here

---

## Section 4 — CTEs & Recursive CTEs (Hard)

### 16. Using a CTE, return the total sales per product, but only for products that generated more than the average product revenue.

sql
-- Write your query here

### 17. Write a recursive CTE to return the full organizational hierarchy starting from the CEO.

sql
-- Write your query here

### 18. Using recursion, calculate the depth level of each employee in the organizational tree.

sql
-- Write your query here

### 19. Generate a calendar table for a full year starting from the minimum order date in the database.

sql
-- Write your query here

### 20. Simulate pagination (page 3 with page size 20) using a CTE and window functions.

sql
-- Write your query here

---

## Section 5 — Stored Procedures (Hard & Practical)

### 21. Create a stored procedure that returns sales for a date range, with null parameters meaning "no filter." (Idempotent CREATE OR ALTER required.)

sql
-- Write your procedure here

### 22. Create a stored procedure that inserts a new product with full validation and returns the new ProductID.

sql
-- Write your procedure here

### 23. Create a stored procedure to deactivate all products that have not been sold in the last 2 years. Wrap the update in a transaction.

sql
-- Write your procedure here

### 24. Write a stored procedure that logs failed login attempts into a tracking table and locks the account after 5 fails within 10 minutes.

sql
-- Write your procedure here

---

## Section 6 — Scalar & Table‑Valued Functions

### 25. Create a scalar function that validates SKU format (AdventureWorks format expected). Returns 1/0.

sql
-- Write your function here

### 26. Create an inline table‑valued function that returns all products priced within ±10% of a given price.

sql
-- Write your function here

### 27. Create a multi‑statement TVF that returns aggregated customer KPIs (order count, total spend, avg order size).

sql
-- Write your function here

---

## Section 7 — Transactions, Locks & Isolation Levels (Challenging)

### 28. Simulate a deadlock using two sessions. Write the SQL script for session A and session B.

**Session A:**
sql
-- Write your session A code

**Session B:**
sql
-- Write your session B code

### 29. Write a script demonstrating phantom reads at READ COMMITTED isolation.

sql
-- Transaction code here

### 30. Rewrite the script to eliminate phantom reads using SERIALIZABLE.

sql
-- Transaction code here

### 31. Create a transaction that updates inventory quantities only if the current quantity matches the expected quantity (optimistic concurrency).

sql
-- Write your code here

---

## Section 8 — Indexing, Performance & Execution Plans (Hard)

### 32. Identify a query over SalesOrderDetail that would benefit from a nonclustered index on (ProductID, OrderQty). Write the query.

sql
-- Write your query here

### 33. Propose and write the CREATE INDEX statement that improves the query from question 32.

sql
-- Write your index here

### 34. Write a query on Product that forces a clustered index scan and explain (in one sentence) why the scan occurs.

sql
-- Write your query here (explanation in comment)

### 35. Write a query that is likely to cause a key lookup and then rewrite it to eliminate the key lookup.

**Version 1 (with lookup):**
sql
-- Write your code here

**Version 2 (no lookup):**
sql
-- Write your code here

---

## Section 9 — MERGE (Hard, Real‑World Focus)

### 36. Use MERGE to synchronize a staging Product table with the main Product table (insert/update/delete). Avoid the typical MERGE race condition.

sql
-- Write your MERGE here

### 37. Write a MERGE statement that updates inventory quantities but logs all changes into an audit table using the OUTPUT clause.

sql
-- Write your code here

### 38. Rewrite one of the above MERGE operations into an UPSERT pattern using only INSERT + UPDATE + DELETE (no MERGE).

sql
-- Write your alternative pattern here

---

## Section 10 — Advanced Real‑World Scenarios (Very Hard / Challenge Level)

### 39. Build a query that identifies customer churn: customers who purchased in the last 12–24 months but not in the last 12.

sql
-- Write your query here

### 40. Detect outlier customers whose average order value is more than 3 standard deviations above their territory average.

sql
-- Write your query here

### 41. Find products whose sales rank jumped at least 10 positions month‑over‑month.

sql
-- Write your query here

### 42. Build a materialized aggregate table for daily sales totals. Write the ETL refresh script (incremental).

sql
-- Write your script here

### 43. Create a query that identifies circular references in bill‑of‑materials relationships (use recursive CTE detection).

sql
-- Write your code here

### 44. Write a query to find split shipments: a single sales order where items shipped from multiple warehouses.

sql
-- Write your query here

### 45. Build a dynamic SQL report generator that produces customer KPIs for a given territory and date range. No SQL injection vulnerabilities allowed.

sql
-- Write your code here

---

**If you want more sections (e.g., temporal tables, CDC, partitioning, or query tuning drills), say "continue".**

This exam is intentionally dense and unforgiving.


Copy the entire block above (including the triple backticks) and paste it directly into your GitHub repo as a `.md` file.
