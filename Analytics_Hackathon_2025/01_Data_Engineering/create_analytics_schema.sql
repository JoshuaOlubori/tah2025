-- =================================================================
-- Analytics Hackathon 2025: Data Engineering Script
-- Author: [Your Name]
-- Description: Creates a new 'Analytics' schema with aggregated and
--              cleaned tables to serve as a data mart for analysis.
-- =================================================================

-- Create a new schema to hold our analysis tables
-- This separates our work from the main OLTP schema and shows good practice.
CREATE SCHEMA Analytics;
GO

-- =================================================================
-- Table: Analytics.Fact_Sales
-- Description: A central fact table combining sales order headers and details.
--              This table will be the primary source for most of our analysis.
-- =================================================================
WITH SalesData AS (
    -- Step 1: Join header and detail tables to bring all sales data together.
    SELECT
        soh.SalesOrderID,
        soh.OrderDate,
        soh.CustomerID,
        soh.SalesPersonID,
        soh.TerritoryID,
        soh.ShipMethodID,
        -- Differentiate between Online (D2C) and Reseller channels
        CASE WHEN soh.OnlineOrderFlag = 1 THEN 'Online' ELSE 'Reseller' END AS Channel,
        sod.SalesOrderDetailID,
        sod.ProductID,
        sod.OrderQty,
        sod.UnitPrice,
        sod.UnitPriceDiscount,
        sod.LineTotal,
        -- Join to Product to get StandardCost for profitability analysis
        p.StandardCost,
        -- Calculate profit for each line item
        (sod.LineTotal - (p.StandardCost * sod.OrderQty)) AS LineProfit
    FROM
        Sales.SalesOrderHeader soh
    JOIN
        Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN
        Production.Product p ON sod.ProductID = p.ProductID
)
-- Step 2: Create the final Fact_Sales table in the Analytics schema
SELECT
    SalesOrderID,
    OrderDate,
    -- Create a simple date key (YYYYMMDD) for easier time-based joins if needed
    CONVERT(INT, FORMAT(OrderDate, 'yyyyMMdd')) AS DateKey,
    CustomerID,
    SalesPersonID,
    TerritoryID,
    ShipMethodID,
    Channel,
    SalesOrderDetailID,
    ProductID,
    OrderQty,
    UnitPrice,
    UnitPriceDiscount,
    LineTotal,
    StandardCost,
    LineProfit
INTO
    Analytics.Fact_Sales
FROM
    SalesData;
GO

-- =================================================================
-- Table: Analytics.Dim_Product
-- Description: A dimension table for Products, enriched with category data.
-- =================================================================
WITH ProductDetails AS (
    -- Step 1: Join Product with its subcategory and category to flatten the hierarchy.
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        p.ProductNumber,
        p.Color,
        p.StandardCost,
        p.ListPrice,
        p.Size,
        p.Weight,
        psc.Name AS SubcategoryName,
        pc.Name AS CategoryName
    FROM
        Production.Product p
    LEFT JOIN
        Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    LEFT JOIN
        Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
)
-- Step 2: Create the final Dim_Product table
SELECT
    ProductID,
    ProductName,
    ProductNumber,
    Color,
    StandardCost,
    ListPrice,
    Size,
    Weight,
    SubcategoryName,
    CategoryName
INTO
    Analytics.Dim_Product
FROM
    ProductDetails;
GO

PRINT 'Analytics schema and tables created successfully.';

