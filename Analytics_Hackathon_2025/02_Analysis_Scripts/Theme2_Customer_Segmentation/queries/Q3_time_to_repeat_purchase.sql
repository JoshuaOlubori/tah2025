-- Theme 2: Customer Segmentation
-- Question 3: How long does it take for a new online customer to make their second purchase?
-- This query uses the LEAD window function to find the time gap between the first and second purchase.

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
