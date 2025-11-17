-- Theme 3: Product Optimization
-- Question 4: What is the impact of discounts on sales volume and profitability for key subcategories?
-- This query analyzes the relationship between discounts, sales quantity, and profit.
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
  FORMAT(SUM(LineProfit),'C', 'en-US') AS TotalProfit,
  FORMAT(CASE WHEN SUM(OrderQty)=0 THEN NULL ELSE SUM(LineProfit) * 1.0 / SUM(OrderQty) END, 'C', 'en-US') AS ProfitPerUnit
FROM DiscountBuckets
GROUP BY CategoryName, SubcategoryName, DiscountBucket
ORDER BY SubcategoryName, DiscountBucket;