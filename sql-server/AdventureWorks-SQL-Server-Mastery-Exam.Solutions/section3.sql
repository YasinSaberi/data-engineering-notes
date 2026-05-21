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
