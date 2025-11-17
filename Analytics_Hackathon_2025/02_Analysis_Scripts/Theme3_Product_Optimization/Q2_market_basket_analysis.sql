-- Theme 3: Product Optimization
-- Question 2: What products are most frequently purchased together? (Market Basket Analysis)
-- This is a classic data mining technique to uncover cross-selling opportunities.

WITH OrderProducts AS (
    -- We only need SalesOrderID and ProductName for this analysis
    SELECT
        fs.SalesOrderID,
        p.ProductName
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Analytics.Dim_Product p ON fs.ProductID = p.ProductID
)
-- Self-join the table to find pairs of products bought in the same order.
SELECT
    a.ProductName AS ProductA,
    b.ProductName AS ProductB,
    COUNT(*) AS Frequency
FROM
    OrderProducts a
JOIN
    OrderProducts b ON a.SalesOrderID = b.SalesOrderID AND a.ProductName < b.ProductName -- a.ProductName < b.ProductName avoids duplicates (A,B) and self-pairs (A,A)
GROUP BY
    a.ProductName,
    b.ProductName
ORDER BY
    Frequency DESC


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
