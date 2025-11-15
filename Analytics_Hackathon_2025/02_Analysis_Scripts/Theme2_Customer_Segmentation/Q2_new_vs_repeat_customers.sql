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
