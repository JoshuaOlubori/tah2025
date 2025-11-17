CREATE VIEW Analytics.v_ChannelOrderMetrics AS
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
  AVG(OrderTotalValue) AS AverageOrderValue,
  AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
  COUNT(*) AS TotalOrders
FROM OrderMetrics
GROUP BY Channel;
