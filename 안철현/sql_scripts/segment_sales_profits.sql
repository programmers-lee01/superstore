-- segment 별 매출, 수익
select segment, round(sum(sales), 2) sales, round(sum(profit), 2) profits
from superstore
group by 1
order by 2 desc, 3 desc;