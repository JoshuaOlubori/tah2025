-- Theme 1: Channel Performance
-- Question 4: What is the average order value (AOV) and average items per order for each channel?
-- This query helps understand the fundamental purchasing behavior differences between channels.

WITH OrderMetrics AS (
    -- First, calculate the total value and item count for each individual order
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
-- Now, average these metrics across all orders for each channel
SELECT
    Channel,
    FORMAT(AVG(OrderTotalValue), 'C', 'en-US') AS AverageOrderValue,
    AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
    COUNT(SalesOrderID) AS TotalOrders
FROM
    OrderMetrics
GROUP BY
    Channel
ORDER BY
    Channel;