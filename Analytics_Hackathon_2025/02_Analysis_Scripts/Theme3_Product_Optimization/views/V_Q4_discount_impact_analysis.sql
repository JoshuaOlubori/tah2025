CREATE VIEW Analytics.vDiscountImpact AS
WITH DiscountAnalysis AS (
    SELECT
        p.CategoryName,
        p.SubcategoryName,
        fs.UnitPriceDiscount,
        SUM(fs.OrderQty) AS TotalQuantitySold,
        SUM(fs.LineProfit) AS TotalProfit
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    WHERE p.SubcategoryName IN ('Mountain Bikes', 'Road Bikes', 'Jerseys', 'Helmets')
    GROUP BY p.CategoryName, p.SubcategoryName, fs.UnitPriceDiscount
)
SELECT
    CategoryName,
    SubcategoryName,
    FORMAT(UnitPriceDiscount, 'P') AS DiscountPercentage,
    TotalQuantitySold,
    FORMAT(TotalProfit, 'C', 'en-US') AS TotalProfit,
    FORMAT(TotalProfit / NULLIF(TotalQuantitySold, 0), 'C', 'en-US') AS ProfitPerUnit
FROM DiscountAnalysis
WHERE UnitPriceDiscount > 0
ORDER BY SubcategoryName, UnitPriceDiscount;