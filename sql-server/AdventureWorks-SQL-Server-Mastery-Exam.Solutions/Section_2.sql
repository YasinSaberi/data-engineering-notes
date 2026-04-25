-- 1
SELECT
    e.BusinessEntityID AS EmployeeID,
    e.JobTitle AS EmployeeJobTitle,
    m.BusinessEntityID AS ManagerID,
    m.JobTitle AS ManagerJobTitle
FROM
    HumanResources.Employee e
    LEFT JOIN HumanResources.Employee m ON m.OrganizationNode = e.OrganizationNode.GetAncestor(1);
