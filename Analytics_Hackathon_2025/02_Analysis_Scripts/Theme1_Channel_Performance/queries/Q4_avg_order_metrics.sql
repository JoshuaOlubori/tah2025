-- Theme 1: Channel Performance
-- Question 4: What is the average order value (AOV) and average items per order for each channel?


WITH OrderMetrics AS (
  SELECT
    SalesOrderID,
    Channel,
    SUM(LineTotal) AS OrderTotalValue,
    COUNT(SalesOrderDetailID) AS ItemsPerOrder
  FROM Analytics.Fact_Sales
  GROUP BY SalesOrderID, Channel
)
SELECT
  Channel,
  FORMAT(AVG(OrderTotalValue), 'C', 'en-US') AS AverageOrderValue,
  AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
  COUNT(*) AS TotalOrders
FROM OrderMetrics
GROUP BY Channel;    