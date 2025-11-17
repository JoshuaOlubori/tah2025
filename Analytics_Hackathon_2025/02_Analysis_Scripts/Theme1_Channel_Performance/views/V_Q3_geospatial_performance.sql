CREATE VIEW Analytics.vResellerTerritoryYoY AS
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