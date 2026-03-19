{{
    config(
        materialized = 'table',
    )
}}

with date_range as (

    select
        dateadd(day, seq4(), '1992-01-01'::date) as date_day
    from table(generator(rowcount => 15000))

)

select
    date_day
from date_range
where date_day >= '1992-01-01'
  and date_day < '2000-01-01'
