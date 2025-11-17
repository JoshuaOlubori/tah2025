-- Theme 1: Channel Performance
-- Question 2: What is the monthly sales trend for each channel? Are there seasonal patterns?
-- This helps identify seasonality and momentum, which is key for inventory and marketing planning.

SELECT
  YEAR(OrderDate) AS OrderYear,
  MONTH(OrderDate) AS OrderMonth,
  DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
  Channel,
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS MonthlyRevenue,
  COUNT(DISTINCT SalesOrderID) AS NumberOfOrders
FROM Analytics.Fact_Sales
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1), Channel;
