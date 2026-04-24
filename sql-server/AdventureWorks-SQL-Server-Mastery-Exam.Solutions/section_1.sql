-- 1
SELECT COUNT(*) AS TotalProducts
FROM Production.Product;

-- 2
SELECT
    ea.EmailAddress,
    p.FirstName,
    p.LastName
FROM
    Sales.Customer c
    INNER JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    INNER JOIN Person.EmailAddress ea on ea.BusinessEntityID = p.BusinessEntityID
ORDER BY
    p.LastName

-- 3
SELECT
    p.ProductID
FROM
    Production.Product p
WHERE
    p.ProductID NOT IN (
        SELECT
            sod.ProductID
        FROM
            Sales.SalesOrderDetail sod
    )

-- 4
WITH RankedProducts AS (
    SELECT 
        pc.Name AS CategoryName,
        p.Name AS ProductName,
        p.ListPrice,
        ROW_NUMBER() OVER (
            PARTITION BY pc.Name 
            ORDER BY p.ListPrice DESC
        ) AS PriceRank
    FROM 
        Production.Product p
        INNER JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        INNER JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
)
SELECT 
    CategoryName,
    ProductName,
    ListPrice
FROM 
    RankedProducts
WHERE 
    PriceRank <= 3
ORDER BY 
    CategoryName, 
    PriceRank;
