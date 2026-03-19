with line_items as (

    select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM

),

orders as (

    select
        o_orderkey  as order_key,
        o_orderdate as order_date
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS

)

select
    li.l_orderkey      as order_key,
    li.l_linenumber    as line_number,
    li.l_quantity      as quantity,
    li.l_extendedprice as extended_price,
    li.l_discount      as discount,
    li.l_tax           as tax,
    li.l_shipdate      as ship_date,
    o.order_date
from line_items li
join orders o on li.l_orderkey = o.order_key
