-- 판매금액(내림차순), 수익금액 별 선순위 도시(city) 30위
select city, round(sum(sales), 2) sales, round(sum(profit), 2) profits
from superstore
group by 1
order by 2 desc, 3 desc
limit 30;