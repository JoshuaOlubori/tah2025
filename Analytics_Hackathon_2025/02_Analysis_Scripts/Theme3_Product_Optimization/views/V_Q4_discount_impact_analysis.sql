CREATE OR ALTER VIEW Analytics.vDiscountImpact AS
WITH DiscountBuckets AS (
  SELECT
    p.CategoryName,
    p.SubcategoryName,
    fs.UnitPriceDiscount,
    CASE
      WHEN fs.UnitPriceDiscount BETWEEN 0 AND 0.05 THEN '0-5%'
      WHEN fs.UnitPriceDiscount > 0.05 AND fs.UnitPriceDiscount <= 0.15 THEN '5-15%'
      WHEN fs.UnitPriceDiscount > 0.15 AND fs.UnitPriceDiscount <= 0.30 THEN '15-30%'
      ELSE '>30%'
    END AS DiscountBucket,
    fs.OrderQty,
    fs.LineProfit
  FROM Analytics.Fact_Sales fs
  JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
  WHERE p.SubcategoryName IN ('Mountain Bikes', 'Road Bikes', 'Jerseys', 'Helmets')
)
SELECT
  CategoryName,
  SubcategoryName,
  DiscountBucket,
  SUM(OrderQty) AS TotalQuantitySold,
  SUM(LineProfit) AS TotalProfit,
  CASE WHEN SUM(OrderQty)=0 THEN NULL ELSE SUM(LineProfit) * 1.0 / SUM(OrderQty) END AS ProfitPerUnit
FROM DiscountBuckets
GROUP BY CategoryName, SubcategoryName, DiscountBucket
ORDER BY SubcategoryName, DiscountBucket;