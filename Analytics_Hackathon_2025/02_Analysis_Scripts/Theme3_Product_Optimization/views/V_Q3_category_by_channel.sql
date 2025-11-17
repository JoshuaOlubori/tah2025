CREATE OR ALTER VIEW Analytics.vCategoryChannelRevenue AS
SELECT
  p.CategoryName,
  SUM(CASE WHEN fs.Channel = 'Online' THEN fs.LineTotal ELSE 0 END) AS OnlineRevenue,
  SUM(CASE WHEN fs.Channel = 'Reseller' THEN fs.LineTotal ELSE 0 END) AS ResellerRevenue,
  SUM(fs.LineTotal) AS TotalRevenue
FROM Analytics.Fact_Sales fs
JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
GROUP BY p.CategoryName
ORDER BY TotalRevenue DESC;
