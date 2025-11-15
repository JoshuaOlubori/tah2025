-- Theme 2: Customer Segmentation
-- Question 1: Who are our most valuable customers based on RFM (Recency, Frequency, Monetary) analysis?
-- RFM is a powerful marketing segmentation technique. This query uses CTEs and NTILE to score customers.

WITH RFM_Base AS (
    -- Step 1: Calculate Recency, Frequency, and Monetary values for each customer.
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
    WHERE fs.Channel = 'Online' -- Focusing on D2C customers
    GROUP BY
        c.CustomerID, p.FirstName, p.LastName
),
RFM_Scores AS (
    -- Step 2: Score each customer on a scale of 1-4 for each RFM metric.
    -- NTILE(4) creates 4 buckets (quartiles). 4 is best, 1 is worst.
    SELECT
        CustomerID,
        CustomerName,
        Recency,
        Frequency,
        Monetary,
        NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score, -- Lower recency is better, so order DESC
        NTILE(4) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM
        RFM_Base
),
RFM_Final AS (
    -- Step 3: Combine the scores to get a final RFM score and segment.
    SELECT
        CustomerID,
        CustomerName,
        Recency,
        Frequency,
        FORMAT(Monetary, 'C', 'en-US') as Monetary,
        R_Score,
        F_Score,
        M_Score,
        (R_Score + F_Score + M_Score) AS RFM_Score
    FROM
        RFM_Scores
)
-- Step 4: Assign human-readable segments based on the combined score.
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
FROM
    RFM_Final
ORDER BY
    RFM_Score DESC;
