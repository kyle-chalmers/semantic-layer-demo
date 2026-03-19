-- AI Analyst B's approach: revenue by market segment
-- Uses L_EXTENDEDPRICE * (1 - L_DISCOUNT) for "net revenue"
-- Same question, different calculation, different number
--AI_analysis_b
SELECT
    c.C_MKTSEGMENT AS market_segment,
    ROUND(SUM(li.L_EXTENDEDPRICE * (1 - li.L_DISCOUNT)), 2) AS revenue,
    COUNT(DISTINCT o.O_ORDERKEY) AS total_orders
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM li
    ON o.O_ORDERKEY = li.L_ORDERKEY
JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
    ON o.O_CUSTKEY = c.C_CUSTKEY
WHERE o.O_ORDERSTATUS = 'F'  -- only "fulfilled" orders
GROUP BY c.C_MKTSEGMENT
ORDER BY revenue DESC;
