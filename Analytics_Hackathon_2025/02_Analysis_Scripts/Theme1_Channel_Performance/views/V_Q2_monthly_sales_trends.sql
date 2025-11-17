CREATE VIEW Analytics.vMonthlyChannelTrend AS
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    Channel,
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS MonthlyRevenue,
    COUNT(DISTINCT SalesOrderID) AS NumberOfOrders
FROM
    Analytics.Fact_Sales
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate),
    Channel;