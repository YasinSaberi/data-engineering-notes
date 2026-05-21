-- 11
SELECT
    SalesPersonID,
    SUM(TotalDue) OVER(
        PARTITION BY salespersonid
        ORDER BY
            orderdate
    ) AS running_total
FROM
    Sales.SalesOrderHeader
WHERE
    SalesPersonID IS NOT NULL

-- 12
WITH ProductRevenue AS (
    SELECT 
        pc.Name AS CategoryName,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.Name, p.Name
)
SELECT 
    CategoryName,
    ProductName,
    TotalRevenue,
    DENSE_RANK() OVER(
        PARTITION BY CategoryName 
        ORDER BY TotalRevenue DESC
    ) AS RevenueRank
FROM ProductRevenue
ORDER BY CategoryName, RevenueRank;
