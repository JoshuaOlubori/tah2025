-- Theme 3: Product Optimization
-- Question 3: How does product category performance differ across sales channels?
-- This query uses a PIVOT operator to compare channel revenues side-by-side for each product category.

SELECT
  p.CategoryName,
  FORMAT(SUM(CASE WHEN fs.Channel = 'Online' THEN fs.LineTotal ELSE 0 END), 'C') AS OnlineRevenue,
  FORMAT(SUM(CASE WHEN fs.Channel = 'Reseller' THEN fs.LineTotal ELSE 0 END), 'C') AS ResellerRevenue,
  FORMAT(SUM(fs.LineTotal), 'C') AS TotalRevenue
FROM Analytics.Fact_Sales fs
JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
GROUP BY p.CategoryName
ORDER BY TotalRevenue DESC;