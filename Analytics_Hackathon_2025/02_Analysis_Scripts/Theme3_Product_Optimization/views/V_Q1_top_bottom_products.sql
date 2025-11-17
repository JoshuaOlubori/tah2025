CREATE OR ALTER VIEW Analytics.vTopBottomProducts AS
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
  SELECT TOP (10) 'Top 10' AS Category, ProductID, ProductName, CategoryName, SubcategoryName, TotalRevenue, TotalProfit
  FROM ProdAgg ORDER BY TotalRevenue DESC
),
Bottom10 AS (
  SELECT TOP (10) 'Bottom 10' AS Category, ProductID, ProductName, CategoryName, SubcategoryName, TotalRevenue, TotalProfit
  FROM ProdAgg ORDER BY TotalRevenue ASC
)
SELECT *, CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END AS ProfitMargin FROM Top10
UNION ALL
SELECT *, CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END AS ProfitMargin FROM Bottom10;