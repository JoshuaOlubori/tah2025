-- Theme 2: Customer Segmentation
-- Question 2: What is the rate of new vs. repeat customers each month, and what is their average order value?


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