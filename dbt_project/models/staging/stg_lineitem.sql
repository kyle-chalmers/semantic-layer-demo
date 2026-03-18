-- Staging model: TPCH Line Items
-- Renames columns to business-friendly names

SELECT
    L_ORDERKEY AS order_id,
    L_LINENUMBER AS line_number,
    L_PARTKEY AS part_id,
    L_QUANTITY AS quantity,
    L_EXTENDEDPRICE AS extended_price,
    L_DISCOUNT AS discount,
    L_TAX AS tax,
    L_RETURNFLAG AS return_flag,
    L_LINESTATUS AS line_status,
    L_SHIPDATE AS ship_date
FROM {{ source('tpch', 'lineitem') }}
