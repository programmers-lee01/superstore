
-- 전체수준에 해당하는 안전 재고 품목 (분기나 월 별 유동성을 따지지 않음)
WITH Monthly_Sales AS (
    SELECT 
        `Sub-Category`, 
        YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  
        MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Month, 
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Sub-Category`, 
        Year, 
        Month
),
Safety_Stock AS (
    SELECT 
        `Sub-Category`, 
        AVG(Total_Sales) AS Avg_Monthly_Sales,
        STDDEV(Total_Sales) AS StdDev_Monthly_Sales,
        (AVG(Total_Sales) + 1.5 * STDDEV(Total_Sales)) AS Safety_Stock_Level
    FROM 
        Monthly_Sales
    GROUP BY 
        `Sub-Category`
)
SELECT 
    `Sub-Category`, 
    ROUND(Safety_Stock_Level, 2) AS Recommended_Safety_Stock
FROM 
    Safety_Stock
ORDER BY 
    `Sub-Category`;
-- 그러면 월별 유동성을 챙겨야하는 품목과 상시 많은 수량을 대기해야하는 품목은 뭐가있을까?
   
   


/*-- 1. 서브 카테고리별 분기 매출 변동성 및 계절성 분석 
--  분기별 매출의 표준편차 계산 (StdDev_Quarterly_Sales)
WITH Quarterly_Sales AS (
    SELECT 
        `Sub-Category`, 
        YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  
        CASE
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (7, 8, 9) THEN 'Q3'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (10, 11, 12) THEN 'Q4'
        END AS Quarter,
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Sub-Category`, 
        Year, 
        Quarter
)
SELECT 
    `Sub-Category`,
    AVG(Total_Sales) AS Avg_Quarterly_Sales,  -- 서브 카테고리별 평균 분기 매출
    MAX(Total_Sales) - MIN(Total_Sales) AS Sales_Range  -- 서브 카테고리별 분기 매출의 최대-최소 차이 (계절성 지표)
FROM 
    Quarterly_Sales
GROUP BY 
    `Sub-Category`
ORDER BY 
    `Sub-Category`;





-- 2. 분기 매출의 최대-최소 차이 계산 (Sales_Range)
WITH Quarterly_Sales AS (
    SELECT 
        `Sub-Category`, 
        YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  
        CASE
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (7, 8, 9) THEN 'Q3'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (10, 11, 12) THEN 'Q4'
        END AS Quarter,
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Sub-Category`, 
        Year, 
        Quarter
)
SELECT 
    `Sub-Category`,
    MAX(Total_Sales) - MIN(Total_Sales) AS Sales_Range  -- 서브 카테고리별 분기 매출의 최대-최소 차이 (계절성 지표)
FROM 
    Quarterly_Sales
GROUP BY 
    `Sub-Category`
ORDER BY 
    `Sub-Category`;





-- 3. 표준편차와 매출 변동 범위 계산
WITH Quarterly_Sales AS (
    SELECT 
        `Sub-Category`, 
        YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  
        CASE
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (7, 8, 9) THEN 'Q3'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (10, 11, 12) THEN 'Q4'
        END AS Quarter,
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Sub-Category`, 
        Year, 
        Quarter
),
SubCategory_Analysis AS (
    SELECT 
        `Sub-Category`,
        ROUND(AVG(Total_Sales), 2) AS Avg_Quarterly_Sales,
        ROUND(STDDEV(Total_Sales), 2) AS StdDev_Quarterly_Sales,
        ROUND(MAX(Total_Sales) - MIN(Total_Sales), 2) AS Sales_Range
    FROM 
        Quarterly_Sales
    GROUP BY 
        `Sub-Category`
)
SELECT 
    `Sub-Category`,
    Avg_Quarterly_Sales,
    StdDev_Quarterly_Sales,
    Sales_Range,
    CASE
        WHEN StdDev_Quarterly_Sales <= (SELECT ROUND(STDDEV(Total_Sales), 2) FROM Quarterly_Sales) 
             AND Sales_Range <= (SELECT ROUND(MAX(Total_Sales) - MIN(Total_Sales), 2) FROM Quarterly_Sales)
        THEN '상시 유지 품목'
        ELSE '맞춤형 대비 품목'
    END AS Category_Type
FROM 
    SubCategory_Analysis
ORDER BY 
    `Sub-Category`;*/






   
/*
WITH Quarterly_Sales AS (
    SELECT 
        `Sub-Category`, 
        YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  
        CASE
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (1, 2, 3) THEN 'Q1'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (4, 5, 6) THEN 'Q2'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (7, 8, 9) THEN 'Q3'
            WHEN MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) IN (10, 11, 12) THEN 'Q4'
        END AS Quarter,
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Sub-Category`, 
        Year, 
        Quarter
),
SubCategory_Analysis AS (
    SELECT 
        `Sub-Category`,
        AVG(Total_Sales) AS Avg_Quarterly_Sales,
        STDDEV(Total_Sales) AS StdDev_Quarterly_Sales,
        MAX(Total_Sales) - MIN(Total_Sales) AS Sales_Range
    FROM 
        Quarterly_Sales
    GROUP BY 
        `Sub-Category`
),
Quarterly_Recommendations AS (
    SELECT
        `Sub-Category`,
        Quarter,
        ROUND(AVG(Total_Sales) + (2 * STDDEV(Total_Sales)), 2) AS Recommended_Stock
    FROM 
        Quarterly_Sales
    GROUP BY
        `Sub-Category`,
        Quarter
)
SELECT 
    SCA.`Sub-Category`,
    CASE
        WHEN SCA.StdDev_Quarterly_Sales <= (SELECT STDDEV(Total_Sales) FROM Quarterly_Sales) 
             AND SCA.Sales_Range <= (SELECT MAX(Total_Sales) - MIN(Total_Sales) FROM Quarterly_Sales)
        THEN ROUND(SCA.Avg_Quarterly_Sales + (1.5 * SCA.StdDev_Quarterly_Sales), 2)
        ELSE NULL
    END AS Always_on_items,
    CASE
        WHEN SCA.StdDev_Quarterly_Sales > (SELECT STDDEV(Total_Sales) FROM Quarterly_Sales) 
             OR SCA.Sales_Range > (SELECT MAX(Total_Sales) - MIN(Total_Sales) FROM Quarterly_Sales)
        THEN GROUP_CONCAT(QR.Recommended_Stock ORDER BY QR.Quarter SEPARATOR ', ')
        ELSE NULL
    END AS Custom_contrast_items,
    CASE
        WHEN SCA.StdDev_Quarterly_Sales <= (SELECT STDDEV(Total_Sales) FROM Quarterly_Sales) 
             AND SCA.Sales_Range <= (SELECT MAX(Total_Sales) - MIN(Total_Sales) FROM Quarterly_Sales)
        THEN '상시 유지 품목'
        ELSE '맞춤형 대비 품목'
    END AS Category_Type
FROM 
    SubCategory_Analysis SCA
LEFT JOIN
    Quarterly_Recommendations QR
    ON SCA.`Sub-Category` = QR.`Sub-Category`
GROUP BY
    SCA.`Sub-Category`
ORDER BY 
    SCA.`Sub-Category`;
*/





/*WITH Quarterly_Sales AS (
    SELECT 
        `Region`, 
        `Sub-Category`, 
        CONCAT(YEAR(STR_TO_DATE(`Order Date`, '%Y-%m-%d')), 'Q', QUARTER(STR_TO_DATE(`Order Date`, '%Y-%m-%d'))) AS Quarter,
        ROUND(SUM(`Sales`), 1) AS Total_Sales,
        ROUND(SUM(`Quantity`), 1) AS Total_Quantity,
        ROUND(SUM(`Sales`) / SUM(`Quantity`), 1) AS Avg_Unit_Price
    FROM 
        superstore
    WHERE 1=1 AND 
          `Order Date` IS NOT NULL
    GROUP BY 
        `Region`, 
        `Sub-Category`, 
        YEAR(STR_TO_DATE(`Order Date`, '%Y-%m-%d')), 
        QUARTER(STR_TO_DATE(`Order Date`, '%Y-%m-%d'))
),
Quarterly_Stats AS (
    SELECT
        `Region`,
        `Sub-Category`,
        ROUND(AVG(Total_Sales), 1) AS Avg_Sales,
        ROUND(STDDEV(Total_Sales), 1) AS Std_Sales,
        ROUND(AVG(Total_Quantity), 1) AS Avg_Quantity,
        ROUND(STDDEV(Total_Quantity), 1) AS Std_Quantity,
        ROUND(AVG(Avg_Unit_Price), 1) AS Avg_Unit_Price
    FROM
        Quarterly_Sales
    WHERE `Quarter` IS NOT NULL
    GROUP BY
        `Region`,
        `Sub-Category`
)
SELECT 
    q.`Region`,
    q.`Sub-Category`,
    q.`Quarter`,
    COALESCE(q.`Total_Sales`, 0) AS Total_Sales,
    COALESCE(q.`Total_Quantity`, 0) AS Total_Quantity,
    ROUND(COALESCE((qs.`Avg_Quantity` + (1.65 * qs.`Std_Quantity`)), 0), 1) AS Safety_Stock,
    ROUND(COALESCE((qs.`Avg_Quantity` + (1.65 * qs.`Std_Quantity`)) * qs.`Avg_Unit_Price`, 0), 1) AS Safety_Stock_Value
FROM 
    Quarterly_Sales q
JOIN 
    Quarterly_Stats qs 
ON 
    q.`Region` = qs.`Region` AND q.`Sub-Category` = qs.`Sub-Category`
WHERE 
    q.`Quarter` IS NOT NULL
ORDER BY 
    q.`Region`, 
    q.`Sub-Category`, 
    q.`Quarter`;*/
   
   

   
   
   WITH Monthly_Sales AS (
    SELECT 
        `Region`, 
        `Sub-Category`, 
        DATE_FORMAT(STR_TO_DATE(`Order Date`, '%Y-%m-%d'), '%Y-%m') AS Month,
        CONCAT(YEAR(STR_TO_DATE(`Order Date`, '%Y-%m-%d')), 'Q', QUARTER(STR_TO_DATE(`Order Date`, '%Y-%m-%d'))) AS Quarter,
        ROUND(SUM(`Sales`), 1) AS Total_Sales,
        ROUND(SUM(`Quantity`), 1) AS Total_Quantity
    FROM 
        superstore
    WHERE 1=1 AND 
          `Order Date` IS NOT NULL
    GROUP BY 
        `Region`, 
        `Sub-Category`, 
        DATE_FORMAT(STR_TO_DATE(`Order Date`, '%Y-%m-%d'), '%Y-%m'), 
        YEAR(STR_TO_DATE(`Order Date`, '%Y-%m-%d')), 
        QUARTER(STR_TO_DATE(`Order Date`, '%Y-%m-%d'))
),
Quarterly_Stats AS (
    SELECT
        `Region`,
        `Sub-Category`,
        `Quarter`,
        ROUND(AVG(Total_Sales), 1) AS Avg_Sales,
        ROUND(STDDEV(Total_Sales), 1) AS Std_Sales,
        ROUND(AVG(Total_Quantity), 1) AS Avg_Quantity,
        ROUND(STDDEV(Total_Quantity), 1) AS Std_Quantity,
        ROUND(SUM(Total_Sales) / SUM(Total_Quantity), 1) AS Avg_Unit_Price
    FROM
        Monthly_Sales
    GROUP BY
        `Region`,
        `Sub-Category`,
        `Quarter`
)
SELECT 
    m.`Region`,
    m.`Sub-Category`,
    m.`Quarter`,
    m.`Month`,
    COALESCE(m.`Total_Sales`, 0) AS Total_Sales,
    COALESCE(m.`Total_Quantity`, 0) AS Total_Quantity,
    ROUND(COALESCE((qs.`Avg_Quantity` + (1.65 * qs.`Std_Quantity`)), 0), 1) AS Safety_Stock,
    ROUND(COALESCE((qs.`Avg_Quantity` + (1.65 * qs.`Std_Quantity`)) * qs.`Avg_Unit_Price`, 0), 1) AS Safety_Stock_Value
FROM 
    Monthly_Sales m
JOIN 
    Quarterly_Stats qs 
ON 
    m.`Region` = qs.`Region` AND m.`Sub-Category` = qs.`Sub-Category` AND m.`Quarter` = qs.`Quarter`
ORDER BY 
    m.`Region`, 
    m.`Sub-Category`, 
    m.`Quarter`, 
    m.`Month`;
