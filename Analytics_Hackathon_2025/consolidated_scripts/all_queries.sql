-- Theme 1: Channel Performance
-- Question 1: How does total revenue and profit compare between the 'Online' and 'Reseller' channels on a yearly basis?
-- This query provides a high-level financial overview of the two main sales channels.

SELECT
    YEAR(OrderDate) AS OrderYear,
    Channel,
    -- SUM(LineTotal) gives us the total revenue
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS TotalRevenue,
    -- SUM(LineProfit) gives us the total profit
    FORMAT(SUM(LineProfit), 'C', 'en-US') AS TotalProfit,
    -- Calculate the average profit margin for each channel
    FORMAT(AVG(LineProfit / NULLIF(LineTotal, 0)), 'P') AS AverageProfitMargin
FROM
    Analytics.Fact_Sales
GROUP BY
    YEAR(OrderDate),
    Channel
ORDER BY
    OrderYear,
    Channel;

-- Theme 1: Channel Performance
-- Question 2: What is the monthly sales trend for each channel? Are there seasonal patterns?
-- This helps identify seasonality and momentum, which is key for inventory and marketing planning.

SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    Channel,
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS MonthlyRevenue,
    COUNT(DISTINCT SalesOrderID) AS NumberOfOrders
FROM
    Analytics.Fact_Sales
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate),
    Channel
ORDER BY
    OrderYear,
    OrderMonth,
    Channel;

-- Theme 1: Channel Performance
-- Question 3: Which sales territories are the top performers for the 'Reseller' channel, and how have they grown year-over-year?
-- This query uses a CTE and a window function (LAG) to calculate year-over-year growth for top territories.

WITH TerritorySales AS (
    -- First, aggregate sales by territory and year
    SELECT
        st.Name AS TerritoryName,
        st.[Group] AS TerritoryGroup,
        YEAR(fs.OrderDate) AS OrderYear,
        SUM(fs.LineTotal) AS TotalRevenue
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Sales.SalesTerritory st ON fs.TerritoryID = st.TerritoryID
    WHERE
        fs.Channel = 'Reseller'
    GROUP BY
        st.Name,
        st.[Group],
        YEAR(fs.OrderDate)
),
YoYGrowth AS (
    -- Now, use the LAG window function to get the previous year's sales
    SELECT
        TerritoryName,
        TerritoryGroup,
        OrderYear,
        TotalRevenue,
        LAG(TotalRevenue, 1, 0) OVER(PARTITION BY TerritoryName ORDER BY OrderYear) AS PreviousYearRevenue
    FROM
        TerritorySales
)
-- Finally, calculate the growth rate and display the results
SELECT
    TerritoryName,
    TerritoryGroup,
    OrderYear,
    FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
    FORMAT(PreviousYearRevenue, 'C', 'en-US') AS PreviousYearRevenue,
    -- Calculate Year-over-Year growth percentage
    FORMAT((TotalRevenue - PreviousYearRevenue) / NULLIF(PreviousYearRevenue, 0), 'P') AS YoYGrowthRate
FROM
    YoYGrowth
ORDER BY
    TotalRevenue DESC,
    OrderYear;

-- Theme 1: Channel Performance
-- Question 4: What is the average order value (AOV) and average items per order for each channel?
-- This query helps understand the fundamental purchasing behavior differences between channels.

WITH OrderMetrics AS (
    -- First, calculate the total value and item count for each individual order
    SELECT
        SalesOrderID,
        Channel,
        SUM(LineTotal) AS OrderTotalValue,
        COUNT(SalesOrderDetailID) AS ItemsPerOrder
    FROM
        Analytics.Fact_Sales
    GROUP BY
        SalesOrderID,
        Channel
)
-- Now, average these metrics across all orders for each channel
SELECT
    Channel,
    FORMAT(AVG(OrderTotalValue), 'C', 'en-US') AS AverageOrderValue,
    AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
    COUNT(SalesOrderID) AS TotalOrders
FROM
    OrderMetrics
GROUP BY
    Channel
ORDER BY
    Channel;

-- Theme 1: Channel Performance
-- Question 5: Who are the top 5 salespeople in the Reseller channel by total revenue, and what is their profitability?
-- This query identifies key employees driving the reseller business.

WITH SalesPersonPerformance AS (
    -- Step 1: Aggregate revenue and profit for each salesperson
    SELECT
        fs.SalesPersonID,
        p.FirstName + ' ' + p.LastName AS SalesPersonName,
        SUM(fs.LineTotal) AS TotalRevenue,
        SUM(fs.LineProfit) AS TotalProfit
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Person.Person p ON fs.SalesPersonID = p.BusinessEntityID
    WHERE
        fs.Channel = 'Reseller' AND fs.SalesPersonID IS NOT NULL
    GROUP BY
        fs.SalesPersonID,
        p.FirstName,
        p.LastName
)
-- Step 2: Rank the salespeople and select the top 5
SELECT 
    SalesPersonName,
    FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
    FORMAT(TotalProfit, 'C', 'en-US') AS TotalProfit,
    FORMAT(TotalProfit / NULLIF(TotalRevenue, 0), 'P') AS ProfitMargin,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS Rank
FROM
    SalesPersonPerformance
ORDER BY
    TotalRevenue DESC;

-- Theme 2: Customer Segmentation
-- Question 1: Who are our most valuable customers based on RFM (Recency, Frequency, Monetary) analysis?
-- RFM is a powerful marketing segmentation technique. This query uses CTEs and NTILE to score customers.

WITH RFM_Base AS (
    -- Step 1: Calculate Recency, Frequency, and Monetary values for each customer.
    SELECT
        c.CustomerID,
        p.FirstName + ' ' + p.LastName AS CustomerName,
        MAX(fs.OrderDate) AS LastOrderDate,
        DATEDIFF(day, MAX(fs.OrderDate), GETDATE()) AS Recency,
        COUNT(DISTINCT fs.SalesOrderID) AS Frequency,
        SUM(fs.LineTotal) AS Monetary
    FROM
        Analytics.Fact_Sales fs
    JOIN Sales.Customer c ON fs.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    WHERE fs.Channel = 'Online' -- Focusing on D2C customers
    GROUP BY
        c.CustomerID, p.FirstName, p.LastName
),
RFM_Scores AS (
    -- Step 2: Score each customer on a scale of 1-4 for each RFM metric.
    -- NTILE(4) creates 4 buckets (quartiles). 4 is best, 1 is worst.
    SELECT
        CustomerID,
        CustomerName,
        Recency,
        Frequency,
        Monetary,
        NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score, -- Lower recency is better, so order DESC
        NTILE(4) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM
        RFM_Base
),
RFM_Final AS (
    -- Step 3: Combine the scores to get a final RFM score and segment.
    SELECT
        CustomerID,
        CustomerName,
        Recency,
        Frequency,
        FORMAT(Monetary, 'C', 'en-US') as Monetary,
        R_Score,
        F_Score,
        M_Score,
        (R_Score + F_Score + M_Score) AS RFM_Score
    FROM
        RFM_Scores
)
-- Step 4: Assign human-readable segments based on the combined score.
SELECT
    CustomerID,
    CustomerName,
    Recency,
    Frequency,
    Monetary,
    RFM_Score,
    CASE
        WHEN RFM_Score >= 11 THEN 'Champions'
        WHEN RFM_Score >= 9 THEN 'Loyal Customers'
        WHEN RFM_Score >= 6 THEN 'Potential Loyalists'
        WHEN RFM_Score >= 4 THEN 'At-Risk Customers'
        ELSE 'Lost Customers'
    END AS CustomerSegment
FROM
    RFM_Final
ORDER BY
    RFM_Score DESC;

-- Theme 2: Customer Segmentation
-- Question 2: What is the rate of new vs. repeat customers each month, and what is their average order value?
-- This is vital for understanding customer acquisition and retention effectiveness.

WITH CustomerFirstOrder AS (
    -- Step 1: Find the first order date for each customer.
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate
    FROM
        Analytics.Fact_Sales
    GROUP BY
        CustomerID
),
MonthlyCustomerActivity AS (
    -- Step 2: Tag each order as 'New' or 'Repeat'.
    SELECT
        fs.SalesOrderID,
        fs.CustomerID,
        fs.OrderDate,
        fs.LineTotal,
        CASE
            WHEN FORMAT(fs.OrderDate, 'yyyy-MM') = FORMAT(cfo.FirstOrderDate, 'yyyy-MM') THEN 'New'
            ELSE 'Repeat'
        END AS CustomerType
    FROM
        Analytics.Fact_Sales fs
    JOIN
        CustomerFirstOrder cfo ON fs.CustomerID = cfo.CustomerID
)
-- Step 3: Aggregate the results by month to see the trend.
SELECT
    FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
    CustomerType,
    COUNT(DISTINCT CustomerID) AS NumberOfCustomers,
    FORMAT(SUM(LineTotal) / COUNT(DISTINCT SalesOrderID), 'C', 'en-US') AS AverageOrderValue
FROM
    MonthlyCustomerActivity
GROUP BY
    FORMAT(OrderDate, 'yyyy-MM'),
    CustomerType
ORDER BY
    OrderMonth,
    CustomerType;

-- Theme 2: Customer Segmentation
-- Question 3: How long does it take for a new online customer to make their second purchase?
-- This query uses the LEAD window function to find the time gap between the first and second purchase.

WITH CustomerPurchaseHistory AS (
    -- Step 1: Get all order dates for each customer and rank them
    SELECT
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) as PurchaseNumber
    FROM
        Analytics.Fact_Sales
    WHERE
        Channel = 'Online'
),
FirstToSecondPurchase AS (
    -- Step 2: For each customer, find the date of their first and second purchase
    SELECT
        CustomerID,
        MIN(CASE WHEN PurchaseNumber = 1 THEN OrderDate END) AS FirstPurchaseDate,
        MIN(CASE WHEN PurchaseNumber = 2 THEN OrderDate END) AS SecondPurchaseDate
    FROM
        CustomerPurchaseHistory
    WHERE
        PurchaseNumber <= 2
    GROUP BY
        CustomerID
)
-- Step 3: Calculate the average time difference
SELECT
    AVG(CAST(DATEDIFF(day, FirstPurchaseDate, SecondPurchaseDate) AS FLOAT)) AS AvgDaysToRepeatPurchase
FROM
    FirstToSecondPurchase
WHERE
    SecondPurchaseDate IS NOT NULL; -- Only include customers who have made a second purchase

-- Theme 2: Customer Segmentation
-- Question 4: What is the geographic distribution of our top online customers?
-- This query joins back to the original schema to pull in rich geographic data.

WITH TopCustomers AS (
    -- Step 1: Identify the top 10% of online customers by monetary value
    SELECT
        CustomerID,
        SUM(LineTotal) as TotalSpent
    FROM Analytics.Fact_Sales
    WHERE Channel = 'Online'
    GROUP BY CustomerID
    ORDER BY TotalSpent DESC
    OFFSET 0 ROWS FETCH NEXT (SELECT COUNT(DISTINCT CustomerID) / 10 FROM Analytics.Fact_Sales WHERE Channel = 'Online') ROWS ONLY
)
-- Step 2: Join to get their geographic information
SELECT
    st.Name AS Territory,
    sp.Name AS State,
    a.City,
    COUNT(tc.CustomerID) AS NumberOfTopCustomers
FROM
    TopCustomers tc
JOIN
    Sales.Customer c ON tc.CustomerID = c.CustomerID
JOIN
    Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN
    Person.Address a ON bea.AddressID = a.AddressID
JOIN
    Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN
    Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
GROUP BY
    st.Name,
    sp.Name,
    a.City
ORDER BY
    NumberOfTopCustomers DESC;

-- Theme 3: Product Optimization
-- Question 1: What are the top 10 best and worst-selling products by revenue, and what is their profitability?
-- This helps identify hero products to promote and laggards to potentially discontinue.

-- Using two CTEs to get top and bottom products, then UNION them together.

-- Top 10 Products
WITH RankedTop AS (
    SELECT TOP 10
        'Top 10' AS Category,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        FORMAT(SUM(fs.LineTotal), 'C', 'en-US') AS TotalRevenue,
        FORMAT(SUM(fs.LineProfit), 'C', 'en-US') AS TotalProfit,
        FORMAT(AVG(fs.LineProfit / NULLIF(fs.LineTotal, 0)), 'P') AS ProfitMargin
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    GROUP BY p.ProductName, p.CategoryName, p.SubcategoryName
    ORDER BY SUM(fs.LineTotal) DESC
),
-- Bottom 10 Products
RankedBottom AS (
    SELECT TOP 10
        'Bottom 10' AS Category,
        p.ProductName,
        p.CategoryName,
        p.SubcategoryName,
        FORMAT(SUM(fs.LineTotal), 'C', 'en-US') AS TotalRevenue,
        FORMAT(SUM(fs.LineProfit), 'C', 'en-US') AS TotalProfit,
        FORMAT(AVG(fs.LineProfit / NULLIF(fs.LineTotal, 0)), 'P') AS ProfitMargin
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
    GROUP BY p.ProductName, p.CategoryName, p.SubcategoryName
    ORDER BY SUM(fs.LineTotal) ASC
)
SELECT * FROM RankedTop
UNION ALL
SELECT * FROM RankedBottom;

-- Theme 3: Product Optimization
-- Question 2: What products are most frequently purchased together? (Market Basket Analysis)
-- This is a classic data mining technique to uncover cross-selling opportunities.

WITH OrderProducts AS (
    -- We only need SalesOrderID and ProductName for this analysis
    SELECT
        fs.SalesOrderID,
        p.ProductName
    FROM
        Analytics.Fact_Sales fs
    JOIN
        Analytics.Dim_Product p ON fs.ProductID = p.ProductID
)
-- Self-join the table to find pairs of products bought in the same order.
SELECT
    a.ProductName AS ProductA,
    b.ProductName AS ProductB,
    COUNT(*) AS Frequency
FROM
    OrderProducts a
JOIN
    OrderProducts b ON a.SalesOrderID = b.SalesOrderID AND a.ProductName < b.ProductName -- a.ProductName < b.ProductName avoids duplicates (A,B) and self-pairs (A,A)
GROUP BY
    a.ProductName,
    b.ProductName
ORDER BY
    Frequency DESC

-- Theme 3: Product Optimization
-- Question 3: How does product category performance differ across sales channels?
-- This query uses a PIVOT operator to compare channel revenues side-by-side for each product category.

SELECT
    p.CategoryName,
    FORMAT(SUM(CASE WHEN fs.Channel = 'Online' THEN fs.LineTotal ELSE 0 END), 'C', 'en-US') AS OnlineRevenue,
    FORMAT(SUM(CASE WHEN fs.Channel = 'Reseller' THEN fs.LineTotal ELSE 0 END), 'C', 'en-US') AS ResellerRevenue
FROM
    Analytics.Fact_Sales fs
JOIN
    Analytics.Dim_Product p ON fs.ProductID = p.ProductID
GROUP BY
    p.CategoryName
ORDER BY
    p.CategoryName;

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
