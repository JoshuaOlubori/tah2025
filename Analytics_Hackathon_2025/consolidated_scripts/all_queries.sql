-- ============================================================================
-- CONSOLIDATED SQL QUERIES
-- Analytics Hackathon 2025
-- ============================================================================
-- This file contains all queries from the Analysis_Scripts folder
-- organized by theme
-- ============================================================================

-- ============================================================================
-- THEME 1: CHANNEL PERFORMANCE
-- ============================================================================

-- Theme 1: Channel Performance
-- Question 1: How does total revenue and profit compare between the 'Online' and 'Reseller' channels on a yearly basis?
-- This query provides a high-level financial overview of the two main sales channels.

SELECT
  YEAR(OrderDate) AS OrderYear,
  Channel,
  FORMAT(SUM(LineTotal), 'C', 'en-US') AS TotalRevenue,
    FORMAT(SUM(LineProfit), 'C', 'en-US') AS TotalProfit,
FORMAT(CASE WHEN SUM(LineTotal) = 0 THEN NULL
       ELSE SUM(LineProfit) * 1.0 / SUM(LineTotal) END, 'P') AS ProfitMargin
FROM Analytics.Fact_Sales
GROUP BY YEAR(OrderDate), Channel;

-- ============================================================================

-- Theme 1: Channel Performance
-- Question 2: What is the monthly sales trend for each channel? Are there seasonal patterns?
-- This helps identify seasonality and momentum, which is key for inventory and marketing planning.

SELECT
  YEAR(OrderDate) AS OrderYear,
  MONTH(OrderDate) AS OrderMonth,
  DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
  Channel,
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS MonthlyRevenue,
  COUNT(DISTINCT SalesOrderID) AS NumberOfOrders
FROM Analytics.Fact_Sales
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1), Channel;

-- ============================================================================

-- Theme 1: Channel Performance
-- Question 3: Which sales territories are the top performers for the 'Reseller' channel, and how have they grown year-over-year?
-- This query uses a CTE and a window function (LAG) to calculate year-over-year growth for top territories.

WITH TerritorySales AS (
  SELECT
    st.Name AS TerritoryName,
    st.[Group] AS TerritoryGroup,
    YEAR(fs.OrderDate) AS OrderYear,
    SUM(fs.LineTotal) AS TotalRevenue
  FROM Analytics.Fact_Sales fs
  JOIN Sales.SalesTerritory st ON fs.TerritoryID = st.TerritoryID
  WHERE fs.Channel = 'Reseller'
  GROUP BY st.Name, st.[Group], YEAR(fs.OrderDate)
),
YoY AS (
  SELECT
    TerritoryName,
    TerritoryGroup,
    OrderYear,
    TotalRevenue,
    LAG(TotalRevenue) OVER (PARTITION BY TerritoryName ORDER BY OrderYear) AS PrevRevenue
  FROM TerritorySales
)
SELECT
  TerritoryName,
  TerritoryGroup,
  OrderYear,
  FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
  FORMAT(PrevRevenue, 'C', 'en-US') AS PrevRevenue,
  CASE 
    WHEN PrevRevenue IS NULL OR PrevRevenue = 0 THEN NULL
    ELSE (TotalRevenue - PrevRevenue) * 1.0 / PrevRevenue
  END AS YoYGrowthPct
FROM YoY
ORDER BY TotalRevenue DESC, OrderYear;

-- ============================================================================

-- Theme 1: Channel Performance
-- Question 4: What is the average order value (AOV) and average items per order for each channel?
-- This query helps understand the fundamental purchasing behavior differences between channels.

WITH OrderMetrics AS (
  SELECT
    SalesOrderID,
    Channel,
    SUM(LineTotal) AS OrderTotalValue,
    COUNT(SalesOrderDetailID) AS ItemsPerOrder
  FROM Analytics.Fact_Sales
  GROUP BY SalesOrderID, Channel
)
SELECT
  Channel,
  FORMAT(AVG(OrderTotalValue), 'C', 'en-US') AS AverageOrderValue,
  AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
  COUNT(*) AS TotalOrders
FROM OrderMetrics
GROUP BY Channel;

-- ============================================================================

-- Theme 1: Channel Performance
-- Question 5: Who are the top 5 salespeople in the Reseller channel by total revenue, and what is their profitability?
-- This query identifies key employees driving the reseller business.

WITH SalesPersonPerformance AS (
  SELECT
    fs.SalesPersonID,
    COALESCE(p.FirstName + ' ' + p.LastName, 'Unknown') AS SalesPersonName,
    SUM(fs.LineTotal) AS TotalRevenue,
    SUM(fs.LineProfit) AS TotalProfit
  FROM Analytics.Fact_Sales fs
  LEFT JOIN Person.Person p ON fs.SalesPersonID = p.BusinessEntityID
  WHERE fs.Channel = 'Reseller' AND fs.SalesPersonID IS NOT NULL
  GROUP BY fs.SalesPersonID, p.FirstName, p.LastName
)
SELECT TOP (5)
  SalesPersonName,
 FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
    FORMAT(TotalProfit, 'C', 'en-US') AS TotalProfit,
    FORMAT(
        CASE WHEN TotalRevenue = 0 THEN NULL ELSE TotalProfit * 1.0 / TotalRevenue END,
        'P'
    ) AS ProfitMargin
FROM SalesPersonPerformance
ORDER BY TotalRevenue DESC;

-- ============================================================================
-- THEME 2: CUSTOMER SEGMENTATION
-- ============================================================================

-- Theme 2: Customer Segmentation
-- Question 1: Who are our most valuable customers based on RFM (Recency, Frequency, Monetary) analysis?
-- RFM is a powerful marketing segmentation technique. This query uses CTEs and NTILE to score customers.

WITH RFM_Base AS (
  SELECT
    c.CustomerID,
    COALESCE(p.FirstName + ' ' + p.LastName, 'Company/Unknown') AS CustomerName,
    MAX(fs.OrderDate) AS LastOrderDate,
    DATEDIFF(day, MAX(fs.OrderDate), GETDATE()) AS Recency,
    COUNT(DISTINCT fs.SalesOrderID) AS Frequency,
    SUM(fs.LineTotal) AS Monetary
  FROM Analytics.Fact_Sales fs
  JOIN Sales.Customer c ON fs.CustomerID = c.CustomerID
  LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
  WHERE fs.Channel = 'Online'
  GROUP BY c.CustomerID, p.FirstName, p.LastName
),
RFM_Scores AS (
  SELECT
    CustomerID,
    CustomerName,
    Recency,
    Frequency,
    Monetary,
    NTILE(4) OVER (ORDER BY Recency ASC) AS R_Score,    -- smaller recency = better
    NTILE(4) OVER (ORDER BY Frequency DESC) AS F_Score, -- larger frequency = better
    NTILE(4) OVER (ORDER BY Monetary DESC) AS M_Score   -- larger monetary = better
  FROM RFM_Base
)
SELECT
  CustomerID,
  CustomerName,
  Recency,
  Frequency,
 FORMAT(Monetary, 'C', 'en-US') as Monetary,
  R_Score, F_Score, M_Score,
  (R_Score + F_Score + M_Score) AS RFM_Score,
  CASE
    WHEN (R_Score + F_Score + M_Score) >= 11 THEN 'Champions'
    WHEN (R_Score + F_Score + M_Score) >= 9 THEN 'Loyal Customers'
    WHEN (R_Score + F_Score + M_Score) >= 6 THEN 'Potential Loyalists'
    WHEN (R_Score + F_Score + M_Score) >= 4 THEN 'At-Risk Customers'
    ELSE 'Lost Customers'
  END AS CustomerSegment
FROM RFM_Scores
ORDER BY RFM_Score DESC;

-- ============================================================================

-- Theme 2: Customer Segmentation
-- Question 2: What is the rate of new vs. repeat customers each month, and what is their average order value?
-- This is vital for understanding customer acquisition and retention effectiveness.

WITH CustomerFirstOrder AS (
  SELECT CustomerID, MIN(OrderDate) AS FirstOrderDate
  FROM Analytics.Fact_Sales
  GROUP BY CustomerID
),
MonthlyCustomerActivity AS (
  SELECT
    fs.SalesOrderID,
    fs.CustomerID,
    fs.OrderDate,
    fs.LineTotal,
    CASE WHEN CAST(fs.OrderDate AS DATE) = CAST(cfo.FirstOrderDate AS DATE) THEN 'New' ELSE 'Repeat' END AS CustomerType
  FROM Analytics.Fact_Sales fs
  JOIN CustomerFirstOrder cfo ON fs.CustomerID = cfo.CustomerID
)
SELECT
  FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
  CustomerType,
  COUNT(DISTINCT CustomerID) AS NumberOfCustomers,
    FORMAT(SUM(LineTotal) / COUNT(DISTINCT SalesOrderID), 'C', 'en-US') AS AverageOrderValue
    SUM(LineTotal) * 1.0 / NULLIF(COUNT(DISTINCT SalesOrderID),0) AS AverageOrderValue
FROM MonthlyCustomerActivity
GROUP BY FORMAT(OrderDate, 'yyyy-MM'), CustomerType
ORDER BY OrderMonth, CustomerType;

-- ============================================================================

-- Theme 2: Customer Segmentation
-- Question 3: How long does it take for a new online customer to make their second purchase?
-- This query uses the LEAD window function to find the time gap between the first and second purchase.

WITH Purchases AS (
  SELECT
    CustomerID,
    OrderDate,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS rn,
    LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS NextOrderDate
  FROM Analytics.Fact_Sales
  WHERE Channel = 'Online'
)
SELECT
  AVG(CAST(DATEDIFF(day, OrderDate, NextOrderDate) AS FLOAT)) AS AvgDaysToRepeatPurchase
FROM Purchases
WHERE rn = 1 AND NextOrderDate IS NOT NULL;

-- ============================================================================

-- Theme 2: Customer Segmentation
-- Question 4: What is the geographic distribution of our top online customers?
-- This query joins back to the original schema to pull in rich geographic data.

WITH CustSpend AS (
  SELECT
    fs.CustomerID,
    SUM(fs.LineTotal) AS TotalSpent
  FROM Analytics.Fact_Sales fs
  WHERE fs.Channel = 'Online'
  GROUP BY fs.CustomerID
),
Ranked AS (
  SELECT
    cs.*,
    NTILE(10) OVER (ORDER BY TotalSpent DESC) AS Decile
  FROM CustSpend cs
),
TopDecile AS (
  SELECT CustomerID, TotalSpent FROM Ranked WHERE Decile = 1 -- top 10%
)
SELECT
  st.Name AS Territory,
  sp.Name AS State,
  a.City,
  COUNT(DISTINCT td.CustomerID) AS NumberOfTopCustomers
FROM TopDecile td
JOIN Sales.Customer c ON td.CustomerID = c.CustomerID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
GROUP BY st.Name, sp.Name, a.City
ORDER BY NumberOfTopCustomers DESC;

-- ============================================================================
-- THEME 3: PRODUCT OPTIMIZATION
-- ============================================================================

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

-- ============================================================================

-- Theme 3: Product Optimization
-- Question 2: What products are most frequently purchased together? (Market Basket Analysis)
-- This is a classic data mining technique to uncover cross-selling opportunities.

WITH OrderProducts AS (
 SELECT
        fs.SalesOrderID,
        p.ProductName,
        p.ProductID
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Analytics.Dim_Product p ON fs.ProductID = p.ProductID
)
SELECT
  a.ProductName AS ProductA,
    b.ProductName AS ProductB,
  COUNT(*) AS PairFrequency
FROM OrderProducts a
JOIN OrderProducts b ON a.SalesOrderID = b.SalesOrderID AND a.ProductID < b.ProductID
GROUP BY  a.ProductName,
    b.ProductName
ORDER BY PairFrequency DESC;

-- ============================================================================

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

-- ============================================================================

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

-- ============================================================================
-- END OF CONSOLIDATED QUERIES
-- ============================================================================
