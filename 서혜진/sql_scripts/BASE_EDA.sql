-- 4년 동안 고객수 & 주문수 구하기
select count(distinct `customer name`), count(distinct `Order ID`)
  from superstore_sales_240830;

-- 연도 별 고객수 & 주문수 구하기
select year(order_date_new), count(distinct `customer name`), count(distinct `Order ID`)
  from superstore_sales_240830 
  group by year(order_date_new);
  
-- 연도/분기 별 고객수 & 주문수 구하기
select year(order_date_new) as year, quarter(order_date_new) as quat, count(distinct `customer name`), count(distinct `Order ID`)
  from superstore_sales_240830
  group by year, quat;

-- 고객 당 구매건수
with order_num as (
select `customer id`, count(1) as order_num
  from `sample - superstore_240830`
  group by `customer id`
  order by 2 desc),

  first_order as(
  select `customer id`, min(str_to_date(`Order Date`, '%m/%d/%Y')) as first_order_date
    from `sample - superstore_240830`
    group by `customer id`),

first_order_details as (select a.*, year(a.first_order_date), month(a.first_order_date), dayname(a.first_order_date)
from(select o.*, f.first_order_date from order_num o
  left join first_order f on o.`customer id` = f.`customer id`) a),
  
total_order_num as(select order_num, count(order_num) as cnt
  from first_order_details
  group by order_num
),

total_count AS (
    SELECT SUM(cnt) AS total_cnt
    FROM total_order_num
)

SELECT t.order_num,
       t.cnt,
       t.cnt / total.total_cnt * 100 AS percentage
FROM total_order_num t
CROSS JOIN total_count total
order by 3 desc;


-- 구매건수 별 고객수
select year(order_date_new), count(distinct `customer name`), count(distinct `Order ID`)
  from superstore_sales_240830 
  group by year(order_date_new);

-- 연도/구매건수 별 고객수
select year(order_date_new) as year, quarter(order_date_new) as quart, count(distinct `customer name`), count(distinct `Order ID`)
  from superstore_sales_240830
  group by year, quart;

-- 고객 별 최초 주문일, 마지막 주문일, 최초 주문일과 마지막 주문일 차이
select `customer id`
  , min(order_date_new) as first_order
  , year(min(order_date_new)) as first_order_year
  , month(min(order_date_new)) as first_order_month
  , max(order_date_new) as last_order
  , year(max(order_date_new)) as last_order_year
  , month(max(order_date_new)) as last_order_month
  , datediff(max(order_date_new), min(order_date_new)) as days_between_first_and_last_order
  , timestampdiff(month, min(order_date_new), max(order_date_new)) as months_between_first_and_last_order
  from superstore_sales_240830
  group by `customer id`;

-- 고객 별 최초 주문일, 마지막 주문일, 최초 주문일과 마지막 주문일 차이
select `customer id`
  , min(order_date_new) as first_order
  , year(min(order_date_new)) as first_order_year
  , month(min(order_date_new)) as first_order_month
  , max(order_date_new) as last_order
  , year(max(order_date_new)) as last_order_year
  , month(max(order_date_new)) as last_order_month
  , datediff(max(order_date_new), min(order_date_new)) as days_between_first_and_last_order
  , timestampdiff(month, min(order_date_new), max(order_date_new)) as months_between_first_and_last_order
  from superstore_sales_240830
  group by `customer id`;


-- 고객 별 다음 주문일 계산하기
with unique_order_date as(
 select distinct `customer id`, order_date_new
   from superstore_sales_240830),

next_order_date as (SELECT 
    `customer id`
    , `order_date_new`
    , LEAD(`order_date_new`, 1) OVER (PARTITION BY `customer id` ORDER BY `order_date_new`) AS next_order_date
    FROM unique_order_date 
ORDER BY 
    `customer id`, `order_date_new`)
    
select *
  , datediff(next_order_date, order_date_new) as diff_days
  , TIMESTAMPDIFF(MONTH, `order_date_new`, `next_order_date`) AS diff_months
  from next_order_date 
  where next_order_date is not null;



