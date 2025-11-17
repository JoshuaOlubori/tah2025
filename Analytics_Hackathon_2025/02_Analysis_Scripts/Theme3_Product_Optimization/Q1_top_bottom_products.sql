-- Theme 3: Product Optimization
-- Question 1: What are the top 10 best and worst-selling products by revenue, and what is their profitability?
-- This helps identify hero products to promote and laggards to potentially discontinue.

-- Using two CTEs to get top and bottom products, then UNION them together.

-- Top 10 Products
WITH RankedTop AS (
    SELECT TOP 10
        'Top 10' AS Category,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        FORMAT(SUM(fs.LineTotal), 'C', 'en-US') AS TotalRevenue,
        FORMAT(SUM(fs.LineProfit), 'C', 'en-US') AS TotalProfit,
        FORMAT(AVG(fs.LineProfit / NULLIF(fs.LineTotal, 0)), 'P') AS ProfitMargin
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    GROUP BY p.ProductName, p.CategoryName, p.SubcategoryName
    ORDER BY SUM(fs.LineTotal) DESC
),
-- Bottom 10 Products
RankedBottom AS (
    SELECT TOP 10
        'Bottom 10' AS Category,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        FORMAT(SUM(fs.LineTotal), 'C', 'en-US') AS TotalRevenue,
        FORMAT(SUM(fs.LineProfit), 'C', 'en-US') AS TotalProfit,
        FORMAT(AVG(fs.LineProfit / NULLIF(fs.LineTotal, 0)), 'P') AS ProfitMargin
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    GROUP BY p.ProductName, p.CategoryName, p.SubcategoryName
    ORDER BY SUM(fs.LineTotal) ASC
)
SELECT * FROM RankedTop
UNION ALL
SELECT * FROM RankedBottom;




CREATE VIEW Analytics.vTopBottomProducts AS
WITH RankedTop AS (
    SELECT TOP 10
        'Top 10' AS Category,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        FORMAT(SUM(fs.LineTotal), 'C', 'en-US') AS TotalRevenue,
        FORMAT(SUM(fs.LineProfit), 'C', 'en-US') AS TotalProfit,
        FORMAT(AVG(fs.LineProfit / NULLIF(fs.LineTotal, 0)), 'P') AS ProfitMargin
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    GROUP BY p.ProductName, p.CategoryName, p.SubcategoryName
    ORDER BY SUM(fs.LineTotal) DESC
),
RankedBottom AS (
    SELECT TOP 10
        'Bottom 10' AS Category,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        FORMAT(SUM(fs.LineTotal), 'C', 'en-US') AS TotalRevenue,
        FORMAT(SUM(fs.LineProfit), 'C', 'en-US') AS TotalProfit,
        FORMAT(AVG(fs.LineProfit / NULLIF(fs.LineTotal, 0)), 'P') AS ProfitMargin
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    GROUP BY p.ProductName, p.CategoryName, p.SubcategoryName
    ORDER BY SUM(fs.LineTotal) ASC
)
SELECT * FROM RankedTop
UNION ALL
SELECT * FROM RankedBottom;