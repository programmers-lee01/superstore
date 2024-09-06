/*-- 월별 총수익
SELECT  
    MIN(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Order_Date,
    YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  -- 연도 추출
    MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Month, -- 월 추출
    Round(SUM(Sales),1) as total_sales
FROM 
    superstore
WHERE 
    YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y'))  -- 2018년 이후 데이터만
GROUP BY  
    Year, 
    Month
ORDER BY 
    Year, 
    Month;*/





-- 서브카테고리별 order가 얼마나 이뤄지는지 달 기준
/*SELECT 
    `Sub-Category`, 
    YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  -- 연도 추출
    MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Month, -- 월 추출
    COUNT(`Order ID`) AS Order_Count  -- 주문 건수 집계
FROM 
    superstore
GROUP BY 
    `Sub-Category`, 
    Year, 
    Month
ORDER BY 
    Year, 
    Month, 
    `Sub-Category`;*/











-- 카테고리별 오더
/*SELECT 
    `Sub-Category`, 
    COUNT(`Order ID`) AS Order_Count  -- 주문 건수 집계
FROM 
    superstore
GROUP BY 
    `Sub-Category`
ORDER BY 
    `order_count` desc ;*/
-- binders의 주문과 paper의 주문이 좀 많음






-- 지역별 카테고리의 월별 매출 분석
/*SELECT 
    `Region`, 
    YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Year,  
    MONTH(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS Month, 
    SUM(`sales`) AS sales
from
    superstore
WHERE 
    `Sub-Category` IN ('Binders', 'Paper')
--     AND `Region` = 'Central'  -- 수정된 Region 값
GROUP BY 
    `Region`,
    Year, 
    Month
ORDER BY 
    `Region`;*/

   
   
   
   
   
   
   
   
-- 5. 지역별 평균 매출 계산
/*
SELECT 
    `Region`, 
    `Sub-Category`, 
    ROUND(AVG(`Total_Sales`), 1) AS Avg_Monthly_Sales
FROM (
    SELECT 
        `Region`, 
        `Sub-Category`, 
        `Year`,  
        `Month`, 
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Region`, 
        `Sub-Category`, 
        `Year`, 
        `Month`
) AS Monthly_Data
GROUP BY 
    `Region`, 
    `Sub-Category`
ORDER BY 
    `Region`, 
    `Sub-Category`;
*/









-- SQL 쿼리: 지역별 월별 매출 증감 추이 분석   

-- Monthly_Sales CTE (Common Table Expression): 
-- 		월별로 각 Region 및 Sub-Category에 대한 총 매출을 계산하는 하위 쿼리입니다.
-- LAG 함수: 
-- 		LAG(Total_Sales, 1)는 현재 행의 이전 달의 매출을 가져옵니다. 이를 통해 매출 증감 추이를 계산할 수 있습니다.
-- Sales_Change: 
-- 		현재 달의 매출과 이전 달의 매출 간의 차이를 계산하여, 매출이 증가했는지 감소했는지를 확인합니다.
-- Sales_Change_Percentage: 
-- 		매출 증감율을 퍼센트로 계산하여, 변화의 정도를 더 명확히 파악할 수 있습니다.
/*WITH Monthly_Sales AS (
    SELECT 
        `Region`, 
        YEAR(STR_TO_DATE(`Order Date`, '%Y-%m-%d')) AS Year,  
        MONTH(STR_TO_DATE(`Order Date`, '%Y-%m-%d')) AS Month, 
        `Sub-Category`,
        SUM(`Sales`) AS Total_Sales
    FROM 
        superstore
    GROUP BY 
        `Region`, 
        `Sub-Category`, 
        Year, 
        Month
)
SELECT 
    `Region`,
    `Sub-Category`,
    Year,
    Month,
    Total_Sales,
    LAG(Total_Sales, 1) OVER (PARTITION BY `Region`, `Sub-Category` ORDER BY Year, Month) AS Previous_Month_Sales,
    (Total_Sales - LAG(Total_Sales, 1) OVER (PARTITION BY `Region`, `Sub-Category` ORDER BY Year, Month)) AS Sales_Change,
    ROUND((Total_Sales - LAG(Total_Sales, 1) OVER (PARTITION BY `Region`, `Sub-Category` ORDER BY Year, Month)) / 
          LAG(Total_Sales, 1) OVER (PARTITION BY `Region`, `Sub-Category` ORDER BY Year, Month) * 100, 2) AS Sales_Change_Percentage
FROM 
    Monthly_Sales
ORDER BY 
    `Region`, 
    `Sub-Category`, 
    Year, 
    Month;*/