-- 3개월 단위 코호트 분석

WITH first_purchase AS (
    SELECT `customer id`, MIN(order_date_new) AS cohort_day
    FROM superstore_sales_240830
    GROUP BY `customer id`
),
cohort_day AS (
    SELECT 
        s.*, 
        f.cohort_day, 
        TIMESTAMPDIFF(MONTH, cohort_day, s.order_date_new) AS cohort_index,
        CONCAT(
            YEAR(cohort_day), '-',
            LPAD(((QUARTER(cohort_day) - 1) * 3) + 1, 2, '0'), '-01'
        ) AS cohort_group
    FROM 
        superstore_sales_240830 s 
        LEFT JOIN first_purchase f ON s.`customer id` = f.`customer id`
)
SELECT 
    cohort_group, 
    FLOOR(cohort_index / 3) AS cohort_index, -- Adjusting the cohort index for 3-month periods
    COUNT(DISTINCT `customer id`) AS customer_count
FROM 
    cohort_day
GROUP BY 
    cohort_group, 
    FLOOR(cohort_index / 3)
ORDER BY 
    cohort_group, 
    cohort_index;