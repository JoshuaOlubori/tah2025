-- Theme 3: Product Optimization
-- Question 3: How does product category performance differ across sales channels?
-- This query uses a PIVOT operator to compare channel revenues side-by-side for each product category.

SELECT
    CategoryName,
    FORMAT(ISNULL([Online], 0), 'C', 'en-US') AS OnlineRevenue,
    FORMAT(ISNULL([Reseller], 0), 'C', 'en-US') AS ResellerRevenue
FROM (
    -- Step 1: Get the revenue for each product category and channel
    SELECT
        p.CategoryName,
        fs.Channel,
        fs.LineTotal
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Analytics.Dim_Product p ON fs.ProductID = p.ProductID
) AS SourceData
PIVOT (
    -- Step 2: Pivot the data to create columns for each channel
    SUM(LineTotal)
    FOR Channel IN ([Online], [Reseller])
) AS PivotTable
ORDER BY
    CategoryName;
