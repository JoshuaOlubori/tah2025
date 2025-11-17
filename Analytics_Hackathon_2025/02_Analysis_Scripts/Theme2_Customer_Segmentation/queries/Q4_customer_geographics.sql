-- Theme 2: Customer Segmentation
-- Question 4: What is the geographic distribution of our top online customers?
-- This query joins back to the original schema to pull in rich geographic data.

WITH CustSpend AS (
  SELECT
    fs.CustomerID,
    SUM(fs.LineTotal) AS TotalSpent
  FROM Analytics.Fact_Sales fs
  WHERE fs.Channel = 'Online'
  GROUP BY fs.CustomerID
),
Ranked AS (
  SELECT
    cs.*,
    NTILE(10) OVER (ORDER BY TotalSpent DESC) AS Decile
  FROM CustSpend cs
),
TopDecile AS (
  SELECT CustomerID, TotalSpent FROM Ranked WHERE Decile = 1 -- top 10%
)
SELECT
  st.Name AS Territory,
  sp.Name AS State,
  a.City,
  COUNT(DISTINCT td.CustomerID) AS NumberOfTopCustomers
FROM TopDecile td
JOIN Sales.Customer c ON td.CustomerID = c.CustomerID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
GROUP BY st.Name, sp.Name, a.City
ORDER BY NumberOfTopCustomers DESC;
