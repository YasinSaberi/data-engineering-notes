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
