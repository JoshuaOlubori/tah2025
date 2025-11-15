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
