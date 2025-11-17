-- Theme 3: Product Optimization
-- Question 1: What are the top 10 best and worst-selling products by revenue, and what is their profitability?
-- This helps identify hero products to promote and laggards to potentially discontinue.

-- Using two CTEs to get top and bottom products, then UNION them together.

WITH ProdAgg AS (
  SELECT
    p.ProductID,
    p.ProductName,
    p.CategoryName,
    p.SubcategoryName,
    SUM(fs.LineTotal) AS TotalRevenue,
    SUM(fs.LineProfit) AS TotalProfit
  FROM Analytics.Fact_Sales fs
  JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
  GROUP BY p.ProductID, p.ProductName, p.CategoryName, p.SubcategoryName
),
Top10 AS (
  SELECT TOP (10) 'Top 10' AS Category, ProductID, ProductName, CategoryName, SubcategoryName,  TotalRevenue,  TotalProfit
  FROM ProdAgg ORDER BY TotalRevenue DESC
),
Bottom10 AS (
  SELECT TOP (10) 'Bottom 10' AS Category, ProductID, ProductName, CategoryName, SubcategoryName,TotalRevenue,  TotalProfit
  FROM ProdAgg ORDER BY TotalRevenue ASC
)
SELECT *, FORMAT(CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END, 'P') AS ProfitMargin FROM Top10
UNION ALL
SELECT *, FORMAT(CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END, 'P') AS ProfitMargin FROM Bottom10;