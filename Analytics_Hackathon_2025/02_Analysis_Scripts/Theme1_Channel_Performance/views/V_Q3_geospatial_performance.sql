CREATE VIEW Analytics.v_ResellerTerritoryYoY AS
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
  TotalRevenue,
  PrevRevenue,
  CASE 
    WHEN PrevRevenue IS NULL OR PrevRevenue = 0 THEN NULL
    ELSE (TotalRevenue - PrevRevenue) * 1.0 / PrevRevenue
  END AS YoYGrowthPct
FROM YoY
ORDER BY TotalRevenue DESC, OrderYear;
