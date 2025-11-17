CREATE VIEW Analytics.vTopCustomerGeography AS
WITH TopCustomers AS (
    SELECT
        CustomerID,
        SUM(LineTotal) AS TotalSpent
    FROM Analytics.Fact_Sales
    WHERE Channel = 'Online'
    GROUP BY CustomerID
    ORDER BY TotalSpent DESC
    OFFSET 0 ROWS FETCH NEXT (
        SELECT COUNT(DISTINCT CustomerID) / 10
        FROM Analytics.Fact_Sales
        WHERE Channel = 'Online'
    ) ROWS ONLY
)
SELECT
    st.Name AS Territory,
    sp.Name AS State,
    a.City,
    COUNT(tc.CustomerID) AS NumberOfTopCustomers
FROM TopCustomers tc
JOIN Sales.Customer c ON tc.CustomerID = c.CustomerID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
GROUP BY st.Name, sp.Name, a.City;