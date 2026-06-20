with date_spine as (
    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2016-01-01' as date)",
            end_date="cast('2019-12-31' as date)"
        )
    }}
)

select
    date_day                                     as date_key,
    date_day,
    extract(year from date_day)                  as year,
    extract(month from date_day)                 as month,
    extract(day from date_day)                   as day,
    extract(dayofweek from date_day)              as day_of_week,
    dayname(date_day)                             as day_name,
    monthname(date_day)                           as month_name,
    extract(quarter from date_day)                as quarter,
    case
        when extract(dayofweek from date_day) in (0, 6) then true
        else false
    end                                            as is_weekend
from date_spine