-- 배송(ship_mode) 별 매출, 수익
select ship_mode, round(sum(sales), 2) sales, round(sum(profit), 2) profits
from superstore
group by 1
order by 2 desc, 3 desc;