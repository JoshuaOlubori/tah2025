CREATE VIEW Analytics.vChannelPerformance AS
SELECT
    YEAR(OrderDate) AS OrderYear,
    Channel,
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS TotalRevenue,
    FORMAT(SUM(LineProfit), 'C', 'en-US') AS TotalProfit,
    FORMAT(AVG(LineProfit / NULLIF(LineTotal, 0)), 'P') AS AverageProfitMargin
FROM
    Analytics.Fact_Sales
GROUP BY
    YEAR(OrderDate),
    Channel;    
