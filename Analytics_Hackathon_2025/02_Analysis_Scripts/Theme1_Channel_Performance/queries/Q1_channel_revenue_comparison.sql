-- Theme 1: Channel Performance
-- Question 1: How does total revenue and profit compare between the 'Online' and 'Reseller' channels on a yearly basis?
-- This query provides a high-level financial overview of the two main sales channels.

SELECT
    YEAR(OrderDate) AS OrderYear,
    Channel,
    -- SUM(LineTotal) gives us the total revenue
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS TotalRevenue,
    -- SUM(LineProfit) gives us the total profit
    FORMAT(SUM(LineProfit), 'C', 'en-US') AS TotalProfit,
    -- Calculate the average profit margin for each channel
    FORMAT(AVG(LineProfit / NULLIF(LineTotal, 0)), 'P') AS AverageProfitMargin
FROM
    Analytics.Fact_Sales
GROUP BY
    YEAR(OrderDate),
    Channel
ORDER BY
    OrderYear,
    Channel;