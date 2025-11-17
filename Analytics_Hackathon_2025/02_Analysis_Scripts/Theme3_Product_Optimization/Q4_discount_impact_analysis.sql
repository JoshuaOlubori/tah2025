-- Theme 3: Product Optimization
-- Question 4: What is the impact of discounts on sales volume and profitability for key subcategories?
-- This query analyzes the relationship between discounts, sales quantity, and profit.

WITH DiscountAnalysis AS (
    SELECT
        p.CategoryName,
        p.SubcategoryName,
        fs.UnitPriceDiscount,
        SUM(fs.OrderQty) as TotalQuantitySold,
        SUM(fs.LineProfit) as TotalProfit
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    WHERE
        p.SubcategoryName IN ('Mountain Bikes', 'Road Bikes', 'Jerseys', 'Helmets') -- Focus on key subcategories
    GROUP BY
        p.CategoryName,
        p.SubcategoryName,
        fs.UnitPriceDiscount
)
SELECT
    CategoryName,
    SubcategoryName,
    FORMAT(UnitPriceDiscount, 'P') AS DiscountPercentage,
    TotalQuantitySold,
    FORMAT(TotalProfit, 'C', 'en-US') AS TotalProfit,
    -- Calculate profit per unit sold at this discount level
    FORMAT(TotalProfit / NULLIF(TotalQuantitySold, 0), 'C', 'en-US') AS ProfitPerUnit
FROM
    DiscountAnalysis
WHERE
    UnitPriceDiscount > 0 -- Only look at sales where a discount was applied
ORDER BY
    SubcategoryName,
    UnitPriceDiscount;



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