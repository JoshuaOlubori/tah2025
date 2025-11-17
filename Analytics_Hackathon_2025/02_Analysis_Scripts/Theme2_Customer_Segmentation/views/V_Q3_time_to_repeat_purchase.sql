CREATE OR ALTER VIEW Analytics.vAvgDaysToSecondPurchase AS
WITH Purchases AS (
  SELECT
    CustomerID,
    OrderDate,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS rn,
    LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate
  FROM Analytics.Fact_Sales
  WHERE Channel = 'Online'
)
SELECT
  AVG(CAST(DATEDIFF(day, OrderDate, NextOrderDate) AS FLOAT)) AS AvgDaysToRepeatPurchase
FROM Purchases
WHERE rn = 1 AND NextOrderDate IS NOT NULL;
