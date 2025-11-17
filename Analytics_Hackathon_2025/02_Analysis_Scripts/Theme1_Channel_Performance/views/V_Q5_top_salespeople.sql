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