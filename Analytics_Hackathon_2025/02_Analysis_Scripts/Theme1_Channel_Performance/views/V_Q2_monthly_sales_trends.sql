CREATE OR ALTER VIEW Analytics.v_ChannelMonthly AS
SELECT
  YEAR(OrderDate) AS OrderYear,
  MONTH(OrderDate) AS OrderMonth,
  DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
  Channel,
  SUM(LineTotal) AS MonthlyRevenue,
  COUNT(DISTINCT SalesOrderID) AS NumberOfOrders
FROM Analytics.Fact_Sales
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1), Channel;
