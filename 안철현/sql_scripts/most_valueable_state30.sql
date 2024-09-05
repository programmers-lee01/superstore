-- 판매금액 합계가 높은 주(state) 30위
select state, round(sum(sales), 2) sales
from superstore
group by 1
order by 2 desc
limit 30;