-- Dimension: one row per day, 2018-01-01 to 2023-03-31 (the data's time range).

with numbers as (

    select top (datediff(day, '2018-01-01', '2023-03-31') + 1)
        row_number() over (order by (select null)) - 1 as n
    from sys.all_objects a cross join sys.all_objects b

)

select
    dateadd(day, n, cast('2018-01-01' as date))                          as date_day,
    year(dateadd(day, n, cast('2018-01-01' as date)))                    as year,
    month(dateadd(day, n, cast('2018-01-01' as date)))                   as month,
    datefromparts(year(dateadd(day, n, cast('2018-01-01' as date))),
            month(dateadd(day, n, cast('2018-01-01' as date))), 1)       as month_start,  
    format(dateadd(day, n, cast('2018-01-01' as date)), 'yyyy-MM')       as year_month,
    datepart(quarter, dateadd(day, n, cast('2018-01-01' as date)))       as quarter,
    case when year(dateadd(day, n, cast('2018-01-01' as date))) between 2018 and 2022
         then 1 else 0 end                                               as is_complete_year
from numbers
