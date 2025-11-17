CREATE VIEW Analytics.vFrequentProductPairs AS
WITH OrderProducts AS (
    SELECT
        fs.SalesOrderID,
        p.ProductName
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
),
RankedPairs AS (
    SELECT
        a.ProductName AS ProductA,
        b.ProductName AS ProductB,
        COUNT(*) AS Frequency
    FROM OrderProducts a
    JOIN OrderProducts b ON a.SalesOrderID = b.SalesOrderID AND a.ProductName < b.ProductName
    GROUP BY a.ProductName, b.ProductName
)
SELECT TOP 20 *
FROM RankedPairs
ORDER BY Frequency DESC;