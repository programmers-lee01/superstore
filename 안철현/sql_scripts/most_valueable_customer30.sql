-- 판매금액 합계가 높은 고객(customer_name) 30위
select customer_name, round(sum(sales), 2) sales
from superstore
group by 1
order by 2 desc
limit 30;