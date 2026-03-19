with source as (

    select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER

)

select
    c_custkey    as customer_key,
    c_name       as customer_name,
    c_mktsegment as market_segment,
    c_nationkey  as nation_key,
    c_acctbal    as account_balance
from source
