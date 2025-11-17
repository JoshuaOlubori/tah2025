CREATE VIEW Analytics.v_RFM_Online AS
WITH RFM_Base AS (
  SELECT
    c.CustomerID,
    COALESCE(p.FirstName + ' ' + p.LastName, 'Company/Unknown') AS CustomerName,
    MAX(fs.OrderDate) AS LastOrderDate,
    DATEDIFF(day, MAX(fs.OrderDate), GETDATE()) AS Recency,
    COUNT(DISTINCT fs.SalesOrderID) AS Frequency,
    SUM(fs.LineTotal) AS Monetary
  FROM Analytics.Fact_Sales fs
  JOIN Sales.Customer c ON fs.CustomerID = c.CustomerID
  LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
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
    NTILE(4) OVER (ORDER BY Recency ASC) AS R_Score,    -- smaller recency = better
    NTILE(4) OVER (ORDER BY Frequency DESC) AS F_Score, -- larger frequency = better
    NTILE(4) OVER (ORDER BY Monetary DESC) AS M_Score   -- larger monetary = better
  FROM RFM_Base
)
SELECT
  CustomerID,
  CustomerName,
  Recency,
  Frequency,
  Monetary,
  R_Score, F_Score, M_Score,
  (R_Score + F_Score + M_Score) AS RFM_Score,
  CASE
    WHEN (R_Score + F_Score + M_Score) >= 11 THEN 'Champions'
    WHEN (R_Score + F_Score + M_Score) >= 9 THEN 'Loyal Customers'
    WHEN (R_Score + F_Score + M_Score) >= 6 THEN 'Potential Loyalists'
    WHEN (R_Score + F_Score + M_Score) >= 4 THEN 'At-Risk Customers'
    ELSE 'Lost Customers'
  END AS CustomerSegment
FROM RFM_Scores
ORDER BY RFM_Score DESC;
