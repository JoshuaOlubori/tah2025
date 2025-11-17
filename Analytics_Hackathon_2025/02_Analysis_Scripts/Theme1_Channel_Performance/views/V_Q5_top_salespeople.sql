CREATE VIEW Analytics.v_TopResellerSalespeople AS
WITH SalesPersonPerformance AS (
  SELECT
    fs.SalesPersonID,
    COALESCE(p.FirstName + ' ' + p.LastName, 'Unknown') AS SalesPersonName,
    SUM(fs.LineTotal) AS TotalRevenue,
    SUM(fs.LineProfit) AS TotalProfit
  FROM Analytics.Fact_Sales fs
  LEFT JOIN Person.Person p ON fs.SalesPersonID = p.BusinessEntityID
  WHERE fs.Channel = 'Reseller' AND fs.SalesPersonID IS NOT NULL
  GROUP BY fs.SalesPersonID, p.FirstName, p.LastName
)
SELECT TOP (5)
  SalesPersonName,
  TotalRevenue,
  TotalProfit,
  CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END AS ProfitMargin
FROM SalesPersonPerformance
ORDER BY TotalRevenue DESC;
