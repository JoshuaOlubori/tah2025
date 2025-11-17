CREATE OR ALTER VIEW Analytics.vChannelOrderMetrics AS
WITH OrderMetrics AS (
    SELECT
        SalesOrderID,
        Channel,
        SUM(LineTotal) AS OrderTotalValue,
        COUNT(SalesOrderDetailID) AS ItemsPerOrder
    FROM
        Analytics.Fact_Sales
    GROUP BY
        SalesOrderID,
        Channel
)
SELECT
    Channel,
    FORMAT(AVG(OrderTotalValue), 'C', 'en-US') AS AverageOrderValue,
    AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
    COUNT(SalesOrderID) AS TotalOrders
FROM
    OrderMetrics
GROUP BY
    Channel;