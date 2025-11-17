-- Theme 2: Customer Segmentation
-- Question 4: What is the geographic distribution of our top online customers?
-- This query joins back to the original schema to pull in rich geographic data.

WITH TopCustomers AS (
    -- Step 1: Identify the top 10% of online customers by monetary value
    SELECT
        CustomerID,
        SUM(LineTotal) as TotalSpent
    FROM Analytics.Fact_Sales
    WHERE Channel = 'Online'
    GROUP BY CustomerID
    ORDER BY TotalSpent DESC
    OFFSET 0 ROWS FETCH NEXT (SELECT COUNT(DISTINCT CustomerID) / 10 FROM Analytics.Fact_Sales WHERE Channel = 'Online') ROWS ONLY
)
-- Step 2: Join to get their geographic information
SELECT
    st.Name AS Territory,
    sp.Name AS State,
    a.City,
    COUNT(tc.CustomerID) AS NumberOfTopCustomers
FROM
    TopCustomers tc
JOIN
    Sales.Customer c ON tc.CustomerID = c.CustomerID
JOIN
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN
    Person.Address a ON bea.AddressID = a.AddressID
JOIN
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN
    Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
GROUP BY
    st.Name,
    sp.Name,
    a.City
ORDER BY
    NumberOfTopCustomers DESC;