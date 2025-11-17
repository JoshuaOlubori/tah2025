CREATE VIEW Analytics.vMonthlyCustomerTypeTrend AS
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