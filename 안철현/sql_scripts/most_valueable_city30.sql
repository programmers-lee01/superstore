-- 판매금액 합계가 높은 도시(city) 30위
select city, round(sum(sales), 2) sales
from superstore
group by 1
order by 2 desc
limit 30;