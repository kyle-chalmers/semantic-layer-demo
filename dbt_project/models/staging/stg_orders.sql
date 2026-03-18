-- Staging model: TPCH Orders
-- Renames columns to business-friendly names

SELECT
    O_ORDERKEY AS order_id,
    O_CUSTKEY AS customer_id,
    O_ORDERSTATUS AS order_status,
    O_TOTALPRICE AS order_total,
    O_ORDERDATE AS order_date,
    O_ORDERPRIORITY AS order_priority
FROM {{ source('tpch', 'orders') }}
