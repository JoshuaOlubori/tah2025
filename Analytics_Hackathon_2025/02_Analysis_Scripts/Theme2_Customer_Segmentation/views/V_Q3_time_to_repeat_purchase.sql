CREATE VIEW Analytics.vAvgDaysToSecondPurchase AS
WITH CustomerPurchaseHistory AS (
    SELECT
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS PurchaseNumber
    FROM Analytics.Fact_Sales
    WHERE Channel = 'Online'
),
FirstToSecondPurchase AS (
    SELECT
        CustomerID,
        MIN(CASE WHEN PurchaseNumber = 1 THEN OrderDate END) AS FirstPurchaseDate,
        MIN(CASE WHEN PurchaseNumber = 2 THEN OrderDate END) AS SecondPurchaseDate
    FROM CustomerPurchaseHistory
    WHERE PurchaseNumber <= 2
    GROUP BY CustomerID
)
SELECT
    AVG(CAST(DATEDIFF(day, FirstPurchaseDate, SecondPurchaseDate) AS FLOAT)) AS AvgDaysToRepeatPurchase
FROM FirstToSecondPurchase
WHERE SecondPurchaseDate IS NOT NULL;