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



    ------------------
    CREATE VIEW Analytics.vTopResellerSalespeople AS
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
