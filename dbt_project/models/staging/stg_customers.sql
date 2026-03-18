-- Staging model: TPCH Customers
-- Renames columns to business-friendly names

SELECT
    C_CUSTKEY AS customer_id,
    C_NAME AS customer_name,
    C_MKTSEGMENT AS market_segment,
    C_NATIONKEY AS nation_id
FROM {{ source('tpch', 'customer') }}
