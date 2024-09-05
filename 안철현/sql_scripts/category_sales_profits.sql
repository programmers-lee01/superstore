-- 카테고리별 매출, 수익, 판매수량
select category, round(sum(sales), 2) sales, round(sum(profit), 2) profits, sum(quantity) quantity
from superstore
group by 1
order by 2 desc, 3 desc, 4 desc;