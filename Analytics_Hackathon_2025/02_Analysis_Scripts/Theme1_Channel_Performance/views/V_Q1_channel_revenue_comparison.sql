CREATE OR ALTER VIEW Analytics.vChannelPerformance AS
SELECT
  YEAR(OrderDate) AS OrderYear,
  Channel,
  SUM(LineTotal) AS TotalRevenue,
  SUM(LineProfit) AS TotalProfit,
  CASE WHEN SUM(LineTotal) = 0 THEN NULL
       ELSE SUM(LineProfit) * 1.0 / SUM(LineTotal) END AS ProfitMargin
FROM Analytics.Fact_Sales
GROUP BY YEAR(OrderDate), Channel;