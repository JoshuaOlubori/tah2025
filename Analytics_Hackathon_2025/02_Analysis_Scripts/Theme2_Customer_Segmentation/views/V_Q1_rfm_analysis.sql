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