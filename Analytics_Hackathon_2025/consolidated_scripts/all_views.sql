CREATE OR ALTER VIEW Analytics.vChannelPerformance AS
SELECT
    YEAR(OrderDate) AS OrderYear,
    Channel,
    FORMAT(SUM(LineTotal), 'C', 'en-US') AS TotalRevenue,
    FORMAT(SUM(LineProfit), 'C', 'en-US') AS TotalProfit,
    FORMAT(AVG(LineProfit / NULLIF(LineTotal, 0)), 'P') AS AverageProfitMargin
FROM
    Analytics.Fact_Sales
GROUP BY
    YEAR(OrderDate),
    Channel;    

CREATE OR ALTER VIEW Analytics.vMonthlyChannelTrend AS
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
    Channel;

CREATE OR ALTER VIEW Analytics.vResellerTerritoryYoY AS
WITH TerritorySales AS (
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
    SELECT
        TerritoryName,
        TerritoryGroup,
        OrderYear,
        TotalRevenue,
        LAG(TotalRevenue, 1, 0) OVER(PARTITION BY TerritoryName ORDER BY OrderYear) AS PreviousYearRevenue
    FROM
        TerritorySales
)
SELECT
    TerritoryName,
    TerritoryGroup,
    OrderYear,
    FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
    FORMAT(PreviousYearRevenue, 'C', 'en-US') AS PreviousYearRevenue,
    FORMAT((TotalRevenue - PreviousYearRevenue) / NULLIF(PreviousYearRevenue, 0), 'P') AS YoYGrowthRate
FROM
    YoYGrowth;

CREATE OR ALTER VIEW Analytics.vChannelOrderMetrics AS
WITH OrderMetrics AS (
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
SELECT
    Channel,
    FORMAT(AVG(OrderTotalValue), 'C', 'en-US') AS AverageOrderValue,
    AVG(CAST(ItemsPerOrder AS FLOAT)) AS AverageItemsPerOrder,
    COUNT(SalesOrderID) AS TotalOrders
FROM
    OrderMetrics
GROUP BY
    Channel;

CREATE OR ALTER VIEW Analytics.vTopResellerSalespeople AS
WITH SalesPersonPerformance AS (
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
SELECT
    SalesPersonName,
    FORMAT(TotalRevenue, 'C', 'en-US') AS TotalRevenue,
    FORMAT(TotalProfit, 'C', 'en-US') AS TotalProfit,
    FORMAT(TotalProfit / NULLIF(TotalRevenue, 0), 'P') AS ProfitMargin,
    RANK() OVER (ORDER BY TotalRevenue DESC) AS Rank
FROM
    SalesPersonPerformance;

CREATE OR ALTER VIEW Analytics.vCustomerRFM AS
WITH RFM_Base AS (
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
        NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM RFM_Base
),
RFM_Final AS (
    SELECT
        CustomerID,
        CustomerName,
        Recency,
        Frequency,
        FORMAT(Monetary, 'C', 'en-US') AS Monetary,
        R_Score,
        F_Score,
        M_Score,
        (R_Score + F_Score + M_Score) AS RFM_Score
    FROM RFM_Scores
)
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
FROM RFM_Final;

CREATE OR ALTER VIEW Analytics.vMonthlyCustomerTypeTrend AS
WITH CustomerFirstOrder AS (
    SELECT
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate
    FROM Analytics.Fact_Sales
    GROUP BY CustomerID
),
MonthlyCustomerActivity AS (
    SELECT
        fs.SalesOrderID,
        fs.CustomerID,
        fs.OrderDate,
        fs.LineTotal,
        CASE
            WHEN FORMAT(fs.OrderDate, 'yyyy-MM') = FORMAT(cfo.FirstOrderDate, 'yyyy-MM') THEN 'New'
            ELSE 'Repeat'
        END AS CustomerType
    FROM Analytics.Fact_Sales fs
    JOIN CustomerFirstOrder cfo ON fs.CustomerID = cfo.CustomerID
)
SELECT
    FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
    CustomerType,
    COUNT(DISTINCT CustomerID) AS NumberOfCustomers,
    FORMAT(SUM(LineTotal) / COUNT(DISTINCT SalesOrderID), 'C', 'en-US') AS AverageOrderValue
FROM MonthlyCustomerActivity
GROUP BY FORMAT(OrderDate, 'yyyy-MM'), CustomerType;

CREATE OR ALTER VIEW Analytics.vAvgDaysToSecondPurchase AS
WITH CustomerPurchaseHistory AS (
    SELECT
        CustomerID,
        OrderDate,
        ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS PurchaseNumber
    FROM Analytics.Fact_Sales
    WHERE Channel = 'Online'
),
FirstToSecondPurchase AS (
    SELECT
        CustomerID,
        MIN(CASE WHEN PurchaseNumber = 1 THEN OrderDate END) AS FirstPurchaseDate,
        MIN(CASE WHEN PurchaseNumber = 2 THEN OrderDate END) AS SecondPurchaseDate
    FROM CustomerPurchaseHistory
    WHERE PurchaseNumber <= 2
    GROUP BY CustomerID
)
SELECT
    AVG(CAST(DATEDIFF(day, FirstPurchaseDate, SecondPurchaseDate) AS FLOAT)) AS AvgDaysToRepeatPurchase
FROM FirstToSecondPurchase
WHERE SecondPurchaseDate IS NOT NULL;

CREATE OR ALTER VIEW Analytics.vTopCustomerGeography AS
WITH TopCustomers AS (
    SELECT
        CustomerID,
        SUM(LineTotal) AS TotalSpent
    FROM Analytics.Fact_Sales
    WHERE Channel = 'Online'
    GROUP BY CustomerID
    ORDER BY TotalSpent DESC
    OFFSET 0 ROWS FETCH NEXT (
        SELECT COUNT(DISTINCT CustomerID) / 10
        FROM Analytics.Fact_Sales
        WHERE Channel = 'Online'
    ) ROWS ONLY
)
SELECT
    st.Name AS Territory,
    sp.Name AS State,
    a.City,
    COUNT(tc.CustomerID) AS NumberOfTopCustomers
FROM TopCustomers tc
JOIN Sales.Customer c ON tc.CustomerID = c.CustomerID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
GROUP BY st.Name, sp.Name, a.City;

CREATE OR ALTER VIEW Analytics.vTopBottomProducts AS
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

CREATE OR ALTER VIEW Analytics.vFrequentProductPairs AS
WITH OrderProducts AS (
    SELECT
        fs.SalesOrderID,
        p.ProductName
    FROM Analytics.Fact_Sales fs
    JOIN Analytics.Dim_Product p ON fs.ProductID = p.ProductID
),
RankedPairs AS (
    SELECT
        a.ProductName AS ProductA,
        b.ProductName AS ProductB,
        COUNT(*) AS Frequency
    FROM OrderProducts a
    JOIN OrderProducts b ON a.SalesOrderID = b.SalesOrderID AND a.ProductName < b.ProductName
    GROUP BY a.ProductName, b.ProductName
)
SELECT TOP 20 *
FROM RankedPairs
ORDER BY Frequency DESC;

CREATE OR ALTER VIEW Analytics.vCategoryChannelRevenue AS
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

CREATE OR ALTER VIEW Analytics.vDiscountImpact AS
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
