-- Theme 2: Customer Segmentation
-- Question 3: How long does it take for a new online customer to make their second purchase?
-- This query uses the LEAD window function to find the time gap between the first and second purchase.

WITH CustomerPurchaseHistory AS (
    -- Step 1: Get all order dates for each customer and rank them
    SELECT
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) as PurchaseNumber
    FROM
        Analytics.Fact_Sales
    WHERE
        Channel = 'Online'
),
FirstToSecondPurchase AS (
    -- Step 2: For each customer, find the date of their first and second purchase
    SELECT
        CustomerID,
        MIN(CASE WHEN PurchaseNumber = 1 THEN OrderDate END) AS FirstPurchaseDate,
        MIN(CASE WHEN PurchaseNumber = 2 THEN OrderDate END) AS SecondPurchaseDate
    FROM
        CustomerPurchaseHistory
    WHERE
        PurchaseNumber <= 2
    GROUP BY
        CustomerID
)
-- Step 3: Calculate the average time difference
SELECT
    AVG(CAST(DATEDIFF(day, FirstPurchaseDate, SecondPurchaseDate) AS FLOAT)) AS AvgDaysToRepeatPurchase
FROM
    FirstToSecondPurchase
WHERE
    SecondPurchaseDate IS NOT NULL; -- Only include customers who have made a second purchase
