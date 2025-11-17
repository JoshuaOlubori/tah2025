-- Theme 1: Channel Performance
-- Question 1: How does total revenue and profit compare between the 'Online' and 'Reseller' channels on a yearly basis?
-- This query provides a high-level financial overview of the two main sales channels.


    SELECT
  YEAR(OrderDate) AS OrderYear,
  Channel,
  FORMAT(SUM(LineTotal), 'C', 'en-US') AS TotalRevenue,
    FORMAT(SUM(LineProfit), 'C', 'en-US') AS TotalProfit,
FORMAT(CASE WHEN SUM(LineTotal) = 0 THEN NULL
       ELSE SUM(LineProfit) * 1.0 / SUM(LineTotal) END, 'P') AS ProfitMargin
FROM Analytics.Fact_Sales
GROUP BY YEAR(OrderDate), Channel;