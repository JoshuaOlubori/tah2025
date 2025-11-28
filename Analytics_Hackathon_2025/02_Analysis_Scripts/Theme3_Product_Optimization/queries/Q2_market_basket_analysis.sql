-- Theme 3: Product Optimization
-- Question 2: What products are most frequently purchased together? (Market Basket Analysis)





    WITH OrderProducts AS (
 SELECT
        fs.SalesOrderID,
        p.ProductName,
        p.ProductID
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Analytics.Dim_Product p ON fs.ProductID = p.ProductID
)
SELECT
  a.ProductName AS ProductA,
    b.ProductName AS ProductB,
  COUNT(*) AS PairFrequency
FROM OrderProducts a
JOIN OrderProducts b ON a.SalesOrderID = b.SalesOrderID AND a.ProductID < b.ProductID
GROUP BY  a.ProductName,
    b.ProductName
ORDER BY PairFrequency DESC;