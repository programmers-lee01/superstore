WITH Recency_Calculated AS (
    SELECT 
        `Customer Name`,
        MAX(STR_TO_DATE(CONCAT('20', RIGHT(`Order Date`, 2), SUBSTRING(`Order Date`, 1, 6)), '%Y%m/%d')) AS Last_Order_Date,
        (SELECT MAX(STR_TO_DATE(CONCAT('20', RIGHT(`Order Date`, 2), SUBSTRING(`Order Date`, 1, 6)), '%Y%m/%d')) FROM super) AS Max_Order_Date,
        DATEDIFF(
            (SELECT MAX(STR_TO_DATE(CONCAT('20', RIGHT(`Order Date`, 2), SUBSTRING(`Order Date`, 1, 6)), '%Y%m/%d')) FROM super), 
            MAX(STR_TO_DATE(CONCAT('20', RIGHT(`Order Date`, 2), SUBSTRING(`Order Date`, 1, 6)), '%Y%m/%d'))
        ) AS Recency
    FROM super
    GROUP BY `Customer Name`
),
Frequency_Calculated AS (
    SELECT 
        `Customer Name`,
        COUNT(DISTINCT `Order ID`) AS Frequency
    FROM 
        super
    GROUP BY 
        `Customer Name`
),
Monetary_Calculated AS (
    SELECT 
        `Customer Name`,
        SUM(`Sales`) AS Monetary_Value
    FROM 
        super
    GROUP BY 
        `Customer Name`
),
Recency_Scored AS (
    SELECT 
        `Customer Name`,
        Recency,
        ROUND((Recency - 150.63) / 191.53, 2) AS Z_Score,
        CASE
            WHEN ROUND((Recency - 150.63) / 191.53, 2) <= -0.5 THEN 5
            WHEN ROUND((Recency - 150.63) / 191.53, 2) <= 0 THEN 4
            WHEN ROUND((Recency - 150.63) / 191.53, 2) <= 0.5 THEN 3
            WHEN ROUND((Recency - 150.63) / 191.53, 2) <= 1 THEN 2
            ELSE 1
        END AS Recency_Score
    FROM Recency_Calculated
),
Frequency_Scored AS (
    SELECT 
        `Customer Name`,
        Frequency,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS Frequency_Score
    FROM Frequency_Calculated
),
Monetary_Scored AS (
    SELECT 
        `Customer Name`,
        Monetary_Value,
        NTILE(5) OVER (ORDER BY Monetary_Value ASC) AS Monetary_Score
    FROM Monetary_Calculated
),
RFM_Segmentation AS (
    SELECT 
        r.`Customer Name`,
        r.`Recency_Score` AS R_Score,
        f.`Frequency_Score` AS F_Score,
        m.`Monetary_Score` AS M_Score,
        m.`Monetary_Value`,
        CASE
            WHEN r.`Recency_Score` >= 4 AND f.`Frequency_Score` >= 4 AND m.`Monetary_Score` >= 4 THEN 'VIP'
            WHEN r.`Recency_Score` >= 4 AND f.`Frequency_Score` >= 4 AND m.`Monetary_Score` <= 3 THEN 'VIP 잠재 고객(1)'
            WHEN r.`Recency_Score` >= 4 AND f.`Frequency_Score` <= 3 AND m.`Monetary_Score` >= 4 THEN 'VIP 잠재 고객(2)'
            WHEN r.`Recency_Score` <= 3 AND f.`Frequency_Score` >= 4 AND m.`Monetary_Score` >= 4 THEN '떠나간 VIP'
            WHEN r.`Recency_Score` >= 4 AND f.`Frequency_Score` <= 2 AND m.`Monetary_Score` <= 2 THEN '신규 고객'
            WHEN r.`Recency_Score` <= 3 AND f.`Frequency_Score` <= 3 AND m.`Monetary_Score` <= 3 THEN '이탈 고객'
            WHEN r.`Recency_Score` = 4 AND f.`Frequency_Score` = 3 AND m.`Monetary_Score` = 3 THEN '관심 필요 고객'
            WHEN r.`Recency_Score` = 3 AND f.`Frequency_Score` = 4 AND m.`Monetary_Score` = 3 THEN '관심 필요 고객'
            WHEN r.`Recency_Score` = 3 AND f.`Frequency_Score` = 3 AND m.`Monetary_Score` = 4 THEN '관심 필요 고객'
            ELSE '기타 고객'
        
        END AS Segment
    FROM 
        Recency_Scored r
    JOIN 
        Frequency_Scored f ON r.`Customer Name` = f.`Customer Name`
    JOIN 
        Monetary_Scored m ON r.`Customer Name` = m.`Customer Name`
)
-- 세그먼트별 고객 수와 총 매출 계산
SELECT 
    Segment,
    COUNT(`Customer Name`) AS Customer_Count,
    SUM(`Monetary_Value`) AS Total_Sales
FROM 
    RFM_Segmentation
GROUP BY 
    Segment
ORDER BY 
    Total_Sales DESC;