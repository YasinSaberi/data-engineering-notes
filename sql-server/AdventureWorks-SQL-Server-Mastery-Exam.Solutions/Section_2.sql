-- 6
SELECT
    e.BusinessEntityID AS EmployeeID,
    e.JobTitle AS EmployeeJobTitle,
    m.BusinessEntityID AS ManagerID,
    m.JobTitle AS ManagerJobTitle
FROM
    HumanResources.Employee e
    LEFT JOIN HumanResources.Employee m ON m.OrganizationNode = e.OrganizationNode.GetAncestor(1);

-- 7
SELECT
    c.CustomerID
FROM
    Sales.Customer c
    LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY
    c.CustomerID
HAVING
    MAX(soh.OrderDate) < DATEADD(MONTH, -6, GETDATE())
    OR MAX(soh.OrderDate) IS NULL;

-- 8
SELECT
    ProductID,
    COUNT(BusinessEntityID) AS NumberOfVendors
FROM
    Purchasing.ProductVendor
GROUP BY
    ProductID
HAVING
    COUNT(BusinessEntityID) > 1;

-- 9
SELECT
    CustomerID,
    CAST(OrderDate AS DATE) AS PureOrderDate,
    COUNT(SalesOrderID) AS OrdersPlaced
FROM
    Sales.SalesOrderHeader
GROUP BY
    CAST(OrderDate AS DATE), 
    CustomerID
HAVING
    COUNT(SalesOrderID) > 1
ORDER BY 
    OrdersPlaced DESC, 
    CustomerID;

-- 10
WITH TerritoryPerformance AS (
    SELECT
        TerritoryID,
        AVG(SalesYTD) AS AvgSalesPerRep
    FROM 
        Sales.SalesPerson
    GROUP BY
        TerritoryID
)
SELECT
    sp.BusinessEntityID,
    sp.TerritoryID,
    sp.SalesYTD,
    tp.AvgSalesPerRep
FROM 
    Sales.SalesPerson AS sp 
    INNER JOIN TerritoryPerformance AS tp ON sp.TerritoryID = tp.TerritoryID
WHERE 
    sp.SalesYTD < tp.AvgSalesPerRep
