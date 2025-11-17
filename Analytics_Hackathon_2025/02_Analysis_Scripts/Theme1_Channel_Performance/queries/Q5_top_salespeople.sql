-- Theme 1: Channel Performance
-- Question 5: Who are the top 5 salespeople in the Reseller channel by total revenue, and what is their profitability?
-- This query identifies key employees driving the reseller business.

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
 FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
    FORMAT(TotalProfit, 'C', 'en-US') AS TotalProfit,
    FORMAT(
        CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END,
        'P'
    ) AS ProfitMargin
FROM SalesPersonPerformance
ORDER BY TotalRevenue DESC;
